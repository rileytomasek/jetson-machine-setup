#!/bin/bash
# Bootstrap a fresh Apple Silicon Mac. Run as the logged-in user, not sudo.
set -euo pipefail

if [[ "${1:-}" == "--help" ]]; then
  printf '%s\n' 'Usage: /bin/bash bootstrap.sh' \
    'Installs Command Line Tools and Homebrew; adds Homebrew to ~/.zprofile.' \
    'If Apple opens an installer, finish it and rerun this script.'
  exit 0
fi
if [[ $# -ne 0 ]]; then
  printf '%s\n' 'Unknown argument. Use --help.' >&2
  exit 1
fi
if [[ "$(/usr/bin/uname -s)" != Darwin || "$(/usr/bin/uname -m)" != arm64 ]]; then
  printf '%s\n' 'Run this in a native Terminal on an Apple Silicon Mac (not Rosetta).' >&2
  exit 1
fi
if [[ "$EUID" -eq 0 ]]; then
  printf '%s\n' 'Run as your normal macOS user, without sudo.' >&2
  exit 1
fi
if [[ ! -t 0 ]]; then
  printf '%s\n' 'Download this file, then run it in Terminal; do not pipe it into bash.' >&2
  exit 1
fi

if ! /usr/bin/xcode-select -p >/dev/null 2>&1 || \
   ! /usr/bin/xcrun --find clang >/dev/null 2>&1; then
  printf '%s\n' 'Requesting Apple Command Line Tools installation.'
  if ! /usr/bin/xcode-select --install; then
    printf '%s\n' 'If no installer appeared, check System Settings > General > Software Update.'
  fi
  printf '%s\n' 'Finish the Apple installer, then rerun this script. Setup is not complete yet.'
  exit 2
fi

if [[ ! -x /opt/homebrew/bin/brew ]]; then
  printf '%s\n' 'Downloading the official Homebrew installer. It will ask for confirmation and may request your Mac password.'
  jetson_installer="$(/usr/bin/mktemp -t jetson-homebrew)"
  trap '/bin/rm -f "$jetson_installer"' EXIT
  /usr/bin/curl --fail --show-error --silent --location --proto '=https' --tlsv1.2 \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
    --output "$jetson_installer"
  /usr/bin/env -u NONINTERACTIVE -u CI INTERACTIVE=1 /bin/bash "$jetson_installer"
fi

jetson_shellenv='eval "$(/opt/homebrew/bin/brew shellenv)"'
jetson_profile="$HOME/.zprofile"
if ! /usr/bin/grep -Fqx "$jetson_shellenv" "$jetson_profile" 2>/dev/null; then
  printf '\n# Homebrew (Jetson setup)\n%s\n' "$jetson_shellenv" >> "$jetson_profile"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
/opt/homebrew/bin/brew --version
/usr/bin/git --version
printf '%s\n' 'Bootstrap complete. Open a new Terminal window to activate Homebrew.' \
  'No apps, runtimes, or account authentications have been configured yet.'
