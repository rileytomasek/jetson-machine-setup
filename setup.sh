#!/bin/bash
set -euo pipefail
if [[ "${1:-}" == --help ]]; then
  printf '%s\n' 'Usage: /bin/bash setup.sh' \
    'Installs apps/tools/runtimes, configures zsh, and opens login apps.' \
    'Does not sign in, start services, or grant macOS permissions.'
  exit 0
fi
[[ $# -eq 0 ]] || { printf '%s\n' 'Unknown argument.' >&2; exit 1; }
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/shell.sh
source "$jetson_root/lib/shell.sh"

# Retains bootstrap's OS, architecture, non-root and interactive checks.
/bin/bash "$jetson_root/bootstrap.sh"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew bundle --file="$jetson_root/Brewfile" --no-upgrade

# Install from the reviewed repository and copy only our owned global fragment.
# Unrelated global settings and per-project runtime overrides remain intact.
jetson_config_dir="${MISE_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/mise}"
jetson_global="$jetson_config_dir/conf.d/jetson.toml"
if [[ -e "$jetson_global" || -L "$jetson_global" ]]; then
  if [[ -L "$jetson_global" ]] || ! grep -Fqx \
    '# Managed by jetson-machine-setup; edit repository mise.toml instead.' "$jetson_global"; then
    printf 'Refusing to replace unowned config: %s\n' "$jetson_global" >&2
    exit 1
  fi
fi
mkdir -p "$jetson_config_dir/conf.d"
mise trust "$jetson_root/mise.toml"
(cd "$jetson_root" && mise install)
if [[ -f "$jetson_global" ]] && ! cmp -s "$jetson_root/mise.toml" "$jetson_global"; then
  jetson_backup="$(mktemp "$jetson_global.backup.XXXXXX")"
  cp "$jetson_global" "$jetson_backup"
  printf 'Previous managed config saved to %s\n' "$jetson_backup"
fi
cp "$jetson_root/mise.toml" "$jetson_global"
mise trust "$jetson_global"
mise reshim

jetson_python="$(tr -d '[:space:]' < "$jetson_root/.python-version")"
# --default supplies python and python3 as well as the versioned executable.
# No --force: existing conflicting executables must be reviewed, not overwritten.
uv python install "$jetson_python" --default
git lfs install --skip-repo
jetson_configure_shell "${ZDOTDIR:-$HOME}"
/bin/bash "$jetson_root/setup-tailscale.sh"
/bin/bash "$jetson_root/setup-login-apps.sh"

/bin/bash "$jetson_root/check.sh"
printf '%s\n' 'Setup complete. Open a new terminal (or run: exec /bin/zsh -l).' \
  'Account sign-in, macOS permissions, power, remote access, and recovery tests remain manual.'
