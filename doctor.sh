#!/usr/bin/env bash

set -uo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/settings.env"

source_root="$script_dir/config"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
local_bin="$HOME/.local/bin"
failures=0
warnings=0

pass() { echo "PASS $*"; }
warn() { echo "WARN $*"; warnings=$((warnings + 1)); }
fail() { echo "FAIL $*"; failures=$((failures + 1)); }

check_manifest() {
  local manifest=$1
  local package
  while IFS= read -r package; do
    [[ -z $package || $package == \#* ]] && continue
    if pacman -Q "$package" >/dev/null 2>&1; then
      pass "package $package"
    else
      fail "package $package is missing"
    fi
  done < "$manifest"
}

check_managed_file() {
  local source=$1
  local target=$2
  if [[ ! -f $target ]]; then
    fail "$target is missing"
  elif cmp -s -- "$source" "$target"; then
    pass "$target is current"
  else
    fail "$target differs from the repository"
  fi
}

check_manifest "$script_dir/packages/official.txt"
check_manifest "$script_dir/packages/aur.txt"

for file in hyprland.lua bindings.lua autostart.lua window-rules.lua input.lua looknfeel.lua monitors.lua hyprsunset.conf xdph.conf; do
  check_managed_file "$source_root/hypr/$file" "$config_root/hypr/$file"
done

check_managed_file "$source_root/solaar/rules.yaml" "$config_root/solaar/rules.yaml"
[[ -r "$source_root/solaar/device-settings.tsv" ]] && pass "recorded Solaar device settings" || fail "recorded Solaar device settings are missing"

for file in \
  mise/config.toml \
  git/system-mirror.config \
  voxtype/config.toml \
  foot/foot.ini \
  systemd/user/voxtype.service \
  omarchy/shell.json \
  omarchy/plugins/jonathan.workspaces/manifest.json \
  omarchy/plugins/jonathan.workspaces/Workspaces.qml \
  Cursor/User/settings.json; do
  check_managed_file "$source_root/$file" "$config_root/$file"
done

if git config --file "$config_root/git/config" --get-all include.path 2>/dev/null | grep -Fqx '~/.config/git/system-mirror.config'; then
  pass "Git SystemMirror include"
else
  fail "Git SystemMirror include is missing"
fi

for binary in omarchy-menu-keybindings-mx system-mirror-lazygit system-mirror-workspace-cycle; do
  check_managed_file "$script_dir/bin/$binary" "$local_bin/$binary"
  [[ -x "$local_bin/$binary" ]] && pass "$binary is executable" || fail "$binary is not executable"
done

for command in codex gh node lazygit solaar voxtype; do
  command -v "$command" >/dev/null 2>&1 && pass "command $command" || fail "command $command is unavailable"
done

[[ $(omarchy default browser 2>/dev/null) == "$SYSTEM_MIRROR_BROWSER" ]] && pass "default browser" || fail "default browser is not $SYSTEM_MIRROR_BROWSER"
[[ $(omarchy default terminal 2>/dev/null) == "$SYSTEM_MIRROR_TERMINAL" ]] && pass "default terminal" || fail "default terminal is not $SYSTEM_MIRROR_TERMINAL"
[[ $(omarchy default editor 2>/dev/null) == "$SYSTEM_MIRROR_EDITOR" ]] && pass "default editor" || fail "default editor is not $SYSTEM_MIRROR_EDITOR"

theme_file="$HOME/.local/state/omarchy/current/theme.name"
if [[ -f $theme_file ]] && [[ $(<"$theme_file") == "$SYSTEM_MIRROR_THEME" ]]; then
  pass "Omarchy theme $SYSTEM_MIRROR_THEME"
else
  fail "Omarchy theme is not $SYSTEM_MIRROR_THEME"
fi

if systemctl --user is-enabled --quiet voxtype.service 2>/dev/null; then
  pass "voxtype.service enabled"
else
  fail "voxtype.service is not enabled"
fi

if systemctl --user is-active --quiet voxtype.service 2>/dev/null; then
  pass "voxtype.service running"
else
  warn "voxtype.service is not currently running"
fi

solaar_config="$config_root/solaar/config.yaml"
if [[ -f $solaar_config ]] && awk '/^[[:space:]]*divert-keys:/ && /195:[[:space:]]*2/ && /196:[[:space:]]*1/ { found=1 } END { exit !found }' "$solaar_config"; then
  pass "MX Master gesture and Smart Shift buttons diverted"
else
  fail "MX Master button diversion is incomplete"
fi

if [[ -f $solaar_config ]] && rg -q 'thumb-scroll-mode:[[:space:]]*true' "$solaar_config"; then
  pass "MX Master thumb wheel diverted"
else
  fail "MX Master thumb wheel diversion is missing"
fi

if [[ -f $solaar_config ]] && rg -q 'fn-swap:[[:space:]]*true' "$solaar_config"; then
  pass "MX Keys S function-key mode"
else
  fail "MX Keys S function-key mode is not configured"
fi

if [[ -f $solaar_config ]] && rg -q 'dpi:[[:space:]]*5000' "$solaar_config"; then
  pass "MX Master DPI 5000"
else
  fail "MX Master DPI is not 5000"
fi

if [[ -f $solaar_config ]] && rg -q 'smart-shift:[[:space:]]*50' "$solaar_config"; then
  pass "MX Master Smart Shift threshold 50"
else
  fail "MX Master Smart Shift threshold is not 50"
fi

pgrep -x solaar >/dev/null 2>&1 && pass "Solaar running" || warn "Solaar is not running"

if command -v hyprctl >/dev/null 2>&1 && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  config_errors=$(hyprctl configerrors 2>&1)
  [[ -z $config_errors ]] && pass "Hyprland reports no configuration errors" || fail "Hyprland configuration errors: $config_errors"
else
  warn "Hyprland runtime check skipped outside an active session"
fi

gh auth status >/dev/null 2>&1 && pass "GitHub CLI authenticated" || warn "GitHub CLI needs 'gh auth login'"

if (( failures > 0 )); then
  echo "SystemMirror Linux doctor found $failures failure(s) and $warnings warning(s)." >&2
  exit 1
fi

echo "SystemMirror Linux doctor passed with $warnings warning(s)."
