#!/bin/bash
set -euo pipefail
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
jetson_version="$(python3 -c "import sys; print('%d.%d' % sys.version_info[:2])")"

# Use the same zsh argument boundary as check.sh, then verify mismatch fails.
/bin/zsh -c 'python3 "$1" "$2"' -- "$jetson_root/check-python.py" "$jetson_version"
if /bin/zsh -c 'python3 "$1" "$2"' -- "$jetson_root/check-python.py" 0.0 2>/dev/null; then
  printf '%s\n' 'FAIL: wrong Python version should fail' >&2
  exit 1
fi
printf '%s\n' 'PASS: Python check runs through zsh and rejects an incorrect version.'
