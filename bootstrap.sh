#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/settings.env"

if (( EUID == 0 )); then
  echo "Run this script as the Omarchy desktop user, not root." >&2
  exit 1
fi

if ! command -v omarchy >/dev/null 2>&1; then
  echo "Install Omarchy first, then rerun $0." >&2
  exit 1
fi

read_manifest() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$1"
}

mapfile -t official_packages < <(read_manifest "$script_dir/packages/official.txt")
if (( ${#official_packages[@]} > 0 )); then
  omarchy pkg add "${official_packages[@]}"
fi

mapfile -t aur_packages < <(read_manifest "$script_dir/packages/aur.txt")
if (( ${#aur_packages[@]} > 0 )); then
  if omarchy pkg aur accessible; then
    omarchy pkg aur add "${aur_packages[@]}"
  else
    echo "AUR is unavailable; rerun bootstrap later to install: ${aur_packages[*]}" >&2
  fi
fi

"$script_dir/apply.sh"

mise install

omarchy default browser "$SYSTEM_MIRROR_BROWSER"
omarchy default terminal "$SYSTEM_MIRROR_TERMINAL"
omarchy default editor "$SYSTEM_MIRROR_EDITOR"
omarchy theme set "$SYSTEM_MIRROR_THEME"

if ! gh auth status >/dev/null 2>&1; then
  echo
  echo "Manual step: run 'gh auth login', then 'gh auth setup-git'."
fi

"$script_dir/doctor.sh"
