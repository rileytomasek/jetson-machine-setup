#!/bin/bash
set -euo pipefail
if [[ "${1:-}" == --help ]]; then
  printf '%s\n' 'Usage: /bin/bash check.sh' 'Checks tools in fresh zsh shells without installing anything.'
  exit 0
fi
[[ $# -eq 0 ]] || { printf '%s\n' 'Unknown argument.' >&2; exit 1; }
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
jetson_python="$(tr -d '[:space:]' < "$jetson_root/.python-version")"
# Test outside the repository so local mise.toml cannot hide missing defaults.
jetson_check_dir="$(mktemp -d -t jetson-check)"
trap 'rmdir "$jetson_check_dir"' EXIT
cd "$jetson_check_dir"
for jetson_mode in -lc -ic -c; do
  printf '\nChecking fresh zsh %s\n' "$jetson_mode"
  # A minimal inherited PATH makes startup configuration do the work.
  PATH=/usr/bin:/bin:/usr/sbin:/sbin /bin/zsh "$jetson_mode" '
    set -eu
    for tool in brew mise uv python python3 node npm bun pnpm go rustc cargo rustfmt ruby gem bundle git gh rg jq fd yq shellcheck shfmt yamllint git-lfs pdftotext ffmpeg magick pandoc gitleaks trivy rclone pkg-config doppler op; do
      command -v "$tool" || { print -u2 "MISSING: $tool"; exit 1; }
    done
    command -v tailscale || { print -u2 "MISSING: tailscale; run bash setup-tailscale.sh"; exit 1; }
    TAILSCALE_BE_CLI=1 tailscale version
    node --version
    bun --version
    pnpm --version
    go version
    rustc --version
    cargo --version
    cargo clippy --version
    rustfmt --version
    ruby --version
    bundle --version
    python --version
    python3 --version
    python -c "import sys; assert '.'.join(map(str, sys.version_info[:2])) == sys.argv[1], sys.version" "$1"
    python3 -c "import sys; assert '.'.join(map(str, sys.version_info[:2])) == sys.argv[1], sys.version" "$1"
    python -c "import ssl, sqlite3, venv; print(\"Python stdlib checks passed\")"
    test "$(python -c "import sys; print(sys.executable)")" = "$(python3 -c "import sys; print(sys.executable)")" ||
      test "$(python -c "import sys; print(sys.prefix)")" = "$(python3 -c "import sys; print(sys.prefix)")"
  ' -- "$jetson_python"
done
printf '\nDeclared package check (no upgrades or installs):\n'
/opt/homebrew/bin/brew bundle check --file="$jetson_root/Brewfile" --no-upgrade
printf '%s\n' 'Tool checks passed. This does not verify accounts, permissions, GUI app PATH, or physical recovery.'
