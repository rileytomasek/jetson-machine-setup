#!/bin/bash
set -euo pipefail
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$jetson_root/lib/shell.sh"
jetson_test_dir="$(mktemp -d -t jetson-shell-test)"
# Only these three known test files are removed; no home directory substitution.
trap 'rm -f "$jetson_test_dir/.zshenv" "$jetson_test_dir/.zprofile" "$jetson_test_dir/.zshrc"; rmdir "$jetson_test_dir"' EXIT
printf '%s\n' '# Existing user configuration' > "$jetson_test_dir/.zshrc"
jetson_configure_shell "$jetson_test_dir"
jetson_before="$(shasum "$jetson_test_dir/.zshenv" "$jetson_test_dir/.zprofile" "$jetson_test_dir/.zshrc")"
jetson_configure_shell "$jetson_test_dir"
test "$jetson_before" = "$(shasum "$jetson_test_dir/.zshenv" "$jetson_test_dir/.zprofile" "$jetson_test_dir/.zshrc")"
grep -Fqx '# Existing user configuration' "$jetson_test_dir/.zshrc"
for mode in -lc -ic -c; do
  ZDOTDIR="$jetson_test_dir" PATH=/usr/bin:/bin /bin/zsh "$mode" '
    [[ "$PATH" == "${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims:${UV_PYTHON_BIN_DIR:-$HOME/.local/bin}:"* ]]
    command -v brew >/dev/null
  '
done
printf '%s\n' 'PASS: repeated setup preserves config and configures login, interactive, and noninteractive zsh PATH.'
