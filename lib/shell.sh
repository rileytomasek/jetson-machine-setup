#!/bin/bash
# Small additive configuration helpers, also exercised by tests/shell.sh.
jetson_append_line() {
  local target="$1" line="$2"
  if ! grep -Fqx "$line" "$target" 2>/dev/null; then
    printf '\n%s\n' "$line" >> "$target"
  fi
}

jetson_configure_shell() {
  local target_dir="$1"
  mkdir -p "$target_dir"
  local path_line='export PATH="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims:${UV_PYTHON_BIN_DIR:-$HOME/.local/bin}:$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"'
  # Keep the original managed line stable for existing installs. Add the
  # vendor launcher directory separately so reruns do not accumulate revisions.
  local vendor_line='export PATH="$PATH:/usr/local/bin"'
  # .zshenv covers noninteractive shells; macOS path_helper in login shells can
  # reorder PATH, so reassert precedence at the end of .zprofile and .zshrc too.
  jetson_append_line "$target_dir/.zshenv" "$path_line"
  jetson_append_line "$target_dir/.zshenv" "$vendor_line"
  jetson_append_line "$target_dir/.zprofile" "$path_line"
  jetson_append_line "$target_dir/.zprofile" "$vendor_line"
  jetson_append_line "$target_dir/.zshrc" "$path_line"
  jetson_append_line "$target_dir/.zshrc" "$vendor_line"
}
