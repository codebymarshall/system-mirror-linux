#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/settings.env"

target_home=$HOME
runtime=1

usage() {
  echo "Usage: $0 [--no-runtime] [--target-home PATH]"
}

while (($#)); do
  case "$1" in
    --no-runtime)
      runtime=0
      shift
      ;;
    --target-home)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      target_home=$2
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

if [[ $target_home != /* ]]; then
  echo "--target-home must be an absolute path." >&2
  exit 2
fi

if (( EUID == 0 )) && [[ $target_home == /root ]]; then
  echo "Run this script as the desktop user, not root." >&2
  exit 1
fi

source_root="$script_dir/config"
config_root="$target_home/.config"
local_bin="$target_home/.local/bin"
updated=0
solaar_rules_updated=0
warnings=0

install_managed_file() {
  local source=$1
  local target=$2
  local mode=$3

  if [[ ! -f $source ]]; then
    echo "FAIL missing source: $source" >&2
    exit 1
  fi

  if [[ -f $target ]] && cmp -s -- "$source" "$target"; then
    echo "OK     $target"
    return 1
  fi

  mkdir -p -- "$(dirname -- "$target")" || {
    echo "FAIL unable to create: $(dirname -- "$target")" >&2
    exit 1
  }
  if [[ -f $target ]]; then
    cp -p -- "$target" "$target.bak"
    echo "BACKUP $target.bak"
  fi

  install -m "$mode" -- "$source" "$target" || {
    echo "FAIL unable to install: $target" >&2
    exit 1
  }
  echo "APPLY  $target"
  updated=1
  return 0
}

for file in hyprland.lua bindings.lua autostart.lua window-rules.lua input.lua looknfeel.lua monitors.lua hyprsunset.conf xdph.conf; do
  install_managed_file "$source_root/hypr/$file" "$config_root/hypr/$file" 0644 || true
done

if install_managed_file "$source_root/solaar/rules.yaml" "$config_root/solaar/rules.yaml" 0644; then
  solaar_rules_updated=1
fi

for file in \
  mise/config.toml \
  git/system-mirror.config \
  voxtype/config.toml \
  foot/foot.ini \
  systemd/user/voxtype.service \
  omarchy/shell.json \
  omarchy/branding/about.png \
  omarchy/branding/about.txt \
  omarchy/branding/screensaver.png \
  omarchy/branding/screensaver.txt \
  omarchy/themes/masseffect/colors.toml \
  omarchy/themes/masseffect/assets/preview.png \
  omarchy/themes/masseffect/backgrounds/wallhaven-y85j1d.png \
  omarchy/plugins/jonathan.movement-breaks/manifest.json \
  omarchy/plugins/jonathan.movement-breaks/BarWidget.qml \
  omarchy/plugins/jonathan.movement-breaks/Service.qml \
  omarchy/plugins/jonathan.movement-breaks/README.md \
  omarchy/plugins/jonathan.workspaces/manifest.json \
  omarchy/plugins/jonathan.workspaces/Workspaces.qml \
  Cursor/User/settings.json; do
  install_managed_file "$source_root/$file" "$config_root/$file" 0644 || true
done

install_managed_file \
  "$source_root/omarchy/plugins/jonathan.movement-breaks/play-sound" \
  "$config_root/omarchy/plugins/jonathan.movement-breaks/play-sound" \
  0755 || true

git_config="$config_root/git/config"
managed_git_include="~/.config/git/system-mirror.config"
mkdir -p -- "$(dirname -- "$git_config")"
if ! git config --file "$git_config" --get-all include.path 2>/dev/null | grep -Fqx "$managed_git_include"; then
  if [[ -f $git_config ]]; then
    cp -p -- "$git_config" "$git_config.bak"
    echo "BACKUP $git_config.bak"
  fi
  git config --file "$git_config" --add include.path "$managed_git_include"
  echo "APPLY  Git SystemMirror include"
  updated=1
fi

for binary in omarchy-menu-keybindings-mx system-mirror-lazygit system-mirror-workspace-cycle system-mirror-workspace-layout-toggle; do
  install_managed_file "$script_dir/bin/$binary" "$local_bin/$binary" 0755 || true
done

if (( runtime == 0 )) || [[ $target_home != "$HOME" ]]; then
  echo "SKIP   runtime configuration"
  exit 0
fi

solaar_set() {
  local device=$1
  shift
  if solaar config "$device" "$@" >/dev/null 2>&1; then
    return 0
  fi

  echo "WARN   Solaar could not apply '$*' to $device; connect or wake the device and rerun." >&2
  warnings=$((warnings + 1))
  return 0
}

if command -v solaar >/dev/null 2>&1; then
  while IFS=$'\t' read -r device_role setting value option; do
    [[ -z $device_role || $device_role == \#* ]] && continue

    case "$device_role" in
      mouse) device=$SYSTEM_MIRROR_MX_MOUSE_ID ;;
      keyboard) device=$SYSTEM_MIRROR_MX_KEYBOARD_ID ;;
      *)
        echo "FAIL   Unknown Solaar device role '$device_role'." >&2
        exit 1
        ;;
    esac

    setting_args=("$setting" "$value")
    [[ -n ${option:-} ]] && setting_args+=("$option")
    solaar_set "$device" "${setting_args[@]}"
  done < "$source_root/solaar/device-settings.tsv"
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl --user daemon-reload
  systemctl --user enable --now voxtype.service
fi

plymouth_logo_source="$source_root/plymouth/omarchy/logo.png"
plymouth_logo_target="/usr/share/plymouth/themes/omarchy/logo.png"
if ! cmp -s -- "$plymouth_logo_source" "$plymouth_logo_target"; then
  sudo install -m 0644 -- "$plymouth_logo_source" "$plymouth_logo_target"
  sudo mkinitcpio -P
  echo "APPLY  Plymouth boot logo"
  updated=1
fi

if command -v hyprctl >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  hyprctl reload >/dev/null
  config_errors=$(hyprctl configerrors)
  if [[ -n $config_errors ]]; then
    echo "FAIL   Hyprland configuration errors:" >&2
    echo "$config_errors" >&2
    exit 1
  fi
  echo "PASS   Hyprland configuration reload"
else
  echo "SKIP   Hyprland reload (no active compositor environment)"
fi

if command -v solaar >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  if pgrep -x solaar >/dev/null 2>&1; then
    if (( solaar_rules_updated )); then
      pkill -x solaar
      setsid -f /usr/bin/solaar --window=hide
      echo "RESTART Solaar"
    fi
  else
    setsid -f /usr/bin/solaar --window=hide
    echo "START   Solaar"
  fi
fi

if (( updated )); then
  echo "SystemMirror Linux configuration applied with $warnings warning(s)."
else
  echo "SystemMirror Linux configuration is current with $warnings warning(s)."
fi
