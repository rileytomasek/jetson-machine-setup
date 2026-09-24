#!/bin/bash
set -euo pipefail
if [[ "${1:-}" == --help ]]; then
  printf '%s\n' 'Usage: /bin/bash setup-tailscale.sh' \
    'Expose the existing Tailscale app CLI; no new daemon, sign-in, or network changes.'
  exit 0
fi
[[ $# -eq 0 ]] || { printf '%s\n' 'Unknown argument.' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { printf '%s\n' 'Run without sudo.' >&2; exit 1; }
if [[ ! -x /Applications/Tailscale.app/Contents/MacOS/Tailscale ]]; then
  printf '%s\n' 'Install Tailscale.app in /Applications before running this step.' >&2
  exit 1
fi
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$jetson_root/lib/shell.sh"
jetson_target="$HOME/.local/bin/tailscale"
if [[ -e "$jetson_target" || -L "$jetson_target" ]]; then
  if [[ -L "$jetson_target" ]] || ! grep -Fqx \
    '# Managed by jetson-machine-setup: Tailscale app CLI wrapper.' "$jetson_target"; then
    printf 'Refusing to replace existing unowned command: %s\n' "$jetson_target" >&2
    exit 1
  fi
fi
mkdir -p "$HOME/.local/bin"
cp "$jetson_root/bin/tailscale" "$jetson_target"
chmod 755 "$jetson_target"
jetson_configure_shell "${ZDOTDIR:-$HOME}"
for mode in -lc -ic -c; do
  PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/zsh "$mode" \
    'set -eu; command -v tailscale; TAILSCALE_BE_CLI=1 tailscale version'
done
printf '%s\n' 'Tailscale CLI ready. Open a new terminal. No connectivity settings were changed.'
