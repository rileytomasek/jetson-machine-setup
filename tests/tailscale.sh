#!/bin/bash
set -euo pipefail
jetson_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$jetson_root/bin/tailscale"
jetson_test_dir="$(mktemp -d -t jetson-tailscale-test)"
trap 'rm -f "$jetson_test_dir/official" "$jetson_test_dir/app"; rmdir "$jetson_test_dir"' EXIT
cp "$jetson_root/tests/fixtures/tailscale" "$jetson_test_dir/official"
cp "$jetson_root/tests/fixtures/tailscale" "$jetson_test_dir/app"
chmod 755 "$jetson_test_dir/official" "$jetson_test_dir/app"
result="$(jetson_tailscale_exec "$jetson_test_dir/official" "$jetson_test_dir/app" status 'two words')"
[[ "$result" == $'cli=1\nexecutable=official\narg=status\narg=two words' ]]
result="$(jetson_tailscale_exec "$jetson_test_dir/absent" "$jetson_test_dir/app" version)"
[[ "$result" == $'cli=1\nexecutable=app\narg=version' ]]
if (jetson_tailscale_exec "$jetson_test_dir/absent" "$jetson_test_dir/absent" version) 2>/dev/null; then
  printf '%s\n' 'FAIL: missing app should fail' >&2
  exit 1
fi
printf '%s\n' 'PASS: official launcher preference, app fallback, CLI mode, argument forwarding, missing-app failure.'
