#!/bin/bash
set -euo pipefail
if [[ "${1:-}" == --help ]]; then
  printf '%s\n' 'Usage: /bin/bash setup-login-apps.sh' \
    'Open Chrome, ChatGPT, and Ghostty when this user logs in.'
  exit 0
fi
[[ $# -eq 0 ]] || { printf '%s\n' 'Unknown argument.' >&2; exit 1; }
[[ "$EUID" -ne 0 ]] || { printf '%s\n' 'Run without sudo.' >&2; exit 1; }

jetson_apps=(
  "/Applications/Google Chrome.app"
  "/Applications/ChatGPT.app"
  "/Applications/Ghostty.app"
)
for jetson_app in "${jetson_apps[@]}"; do
  if ! /usr/bin/open -Ra "$jetson_app" >/dev/null 2>&1; then
    printf 'Required app is not installed: %s\n' "$jetson_app" >&2
    exit 1
  fi
done

jetson_script="$HOME/.local/bin/jetson-open-login-apps"
jetson_agent="$HOME/Library/LaunchAgents/com.jetson.machine-setup.open-login-apps.plist"
if [[ -e "$jetson_script" || -L "$jetson_script" ]]; then
  if [[ -L "$jetson_script" ]] || ! grep -Fqx \
    '# Managed by jetson-machine-setup: open login apps.' "$jetson_script"; then
    printf 'Refusing to replace unowned file: %s\n' "$jetson_script" >&2
    exit 1
  fi
fi
if [[ -e "$jetson_agent" || -L "$jetson_agent" ]]; then
  if [[ -L "$jetson_agent" ]] || ! grep -Fq \
    '<string>com.jetson.machine-setup.open-login-apps</string>' "$jetson_agent"; then
    printf 'Refusing to replace unowned file: %s\n' "$jetson_agent" >&2
    exit 1
  fi
fi

mkdir -p "$(dirname "$jetson_script")" "$(dirname "$jetson_agent")"
cat > "$jetson_script" <<'SCRIPT'
#!/bin/bash
# Managed by jetson-machine-setup: open login apps.
set -euo pipefail
/usr/bin/open -a "/Applications/Google Chrome.app"
/usr/bin/open -a "/Applications/ChatGPT.app"
/usr/bin/open -a "/Applications/Ghostty.app"
SCRIPT
chmod 755 "$jetson_script"
cat > "$jetson_agent" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.jetson.machine-setup.open-login-apps</string>
  <key>ProgramArguments</key>
  <array>
    <string>$jetson_script</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>LimitLoadToSessionType</key>
  <string>Aqua</string>
</dict>
</plist>
PLIST
chmod 644 "$jetson_agent"
printf '%s\n' 'Login app startup configured for the next login.' \
  'To disable it, remove the LaunchAgent in ~/Library/LaunchAgents and the script in ~/.local/bin.'
