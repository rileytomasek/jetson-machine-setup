# Jetson machine setup

Lightweight setup for a dedicated Apple Silicon Mac. Independent of personal
dotfiles: Homebrew owns apps/utilities, mise owns language runtimes, and uv owns Python
environments. No account data, credentials, or infrastructure inventory belongs
in this public repository. No configuration-management framework is required.

## 1. macOS setup (manual)

Complete Setup Assistant, create the intended local account, connect networking,
apply macOS updates, and configure FileVault. Store recovery information outside
this repository in a password manager. Use the default zsh and Terminal.

## 2. Bootstrap (no service authentication)

Download the script in Terminal:

```sh
curl --fail --show-error --location --proto '=https' --tlsv1.2 \
  https://raw.githubusercontent.com/rileytomasek/jetson-machine-setup/main/bootstrap.sh \
  --output ~/Downloads/jetson-bootstrap.sh
less ~/Downloads/jetson-bootstrap.sh
/bin/bash ~/Downloads/jetson-bootstrap.sh
```

Run the last command only after the download succeeds and you review the file.
For a fixed reviewed revision, replace `main` in the URL with its commit SHA.
Do not pipe downloaded content directly into a shell.

The script requests Apple's Command Line Tools installer if needed. Complete
that installer, then rerun it. Exit code 2 means that manual step is pending.
It downloads and runs the official Homebrew installer with confirmation/password
prompts, then adds Homebrew to `~/.zprofile` without replacing existing settings.
Run as the logged-in user, not with sudo. Open a new Terminal afterward.

Internet and local administrator approval are needed; no GitHub or Apple Account
login is required for bootstrap. The upstream Homebrew installer is downloaded
from HEAD, so even a pinned bootstrap is not a fully locked installation.

## 3. Complete setup (also repairs an existing installation)

If you already cloned the repo and ran the earlier instructions:

```sh
cd ~/jetson-workspace/machine-setup
git pull --ff-only
/bin/bash setup.sh
```

Otherwise, after bootstrap:

```sh
mkdir -p ~/jetson-workspace
git clone https://github.com/rileytomasek/jetson-machine-setup.git \
  ~/jetson-workspace/machine-setup
cd ~/jetson-workspace/machine-setup
/bin/bash setup.sh
```

Cloning this public repository requires no authentication. Reuse an existing
clone instead of repeating `git clone`. Homebrew installation can be rerun;
`--no-upgrade` avoids opportunistic upgrades but does not lock package versions.

`setup.sh` performs all of these steps, stopping on failure:

1. Runs the bootstrap checks (Command Line Tools and Homebrew).
2. Installs the Brewfile without upgrading existing packages.
3. Installs Node 24, Bun 1, pnpm 11, stable Go/Rust, and Ruby 3.4 through mise.
   Rust includes Cargo, rustfmt, and Clippy.
4. Copies the runtime manifest into mise's global `conf.d/jetson.toml` fragment
   so defaults work outside this repository. Existing unrelated settings are
   preserved. An unowned file at that path is never overwritten; changed owned
   fragments are backed up. Existing global/project overrides can take priority.
5. Explicitly installs Python 3.13 through uv, including `python`, `python3`,
   and `python3.13`. uv alone is not a Python installation. The version is in
   `.python-version`; `--default` is uv's currently experimental alias option.
6. Initializes Git LFS for the user, without installing a hook in this repo.
7. Adds a small PATH line to `.zshenv`, `.zprofile`, and `.zshrc` (or ZDOTDIR),
   preserving existing content and avoiding duplicate lines on reruns. This
   exposes mise shims, uv's Python executables, and Homebrew in login,
   interactive, and noninteractive zsh shells. No personal dotfiles are copied.
8. Exposes the already installed Tailscale app CLI using `setup-tailscale.sh`.
9. Runs `check.sh` from outside the repo in fresh shells with a minimal inherited
   PATH. Missing commands or broken runtime invocations fail the setup.

Open a new Terminal afterward, or run `exec /bin/zsh -l`. To verify again:

```sh
/bin/bash check.sh
```

Runtime declarations are version tracks, not exact pins; rerunning installation
may resolve newer releases. Projects should declare their own tested versions.
Shims provide ordinary `node`, `bun`, `go`, etc. commands without interactive
mise activation. `mise exec -- <command>` remains useful for explicitly selected
environments. Use `uv venv`/`uv pip` for Python project dependencies; a global pip
installation is not needed. Existing conflicting Python executables are not
force-overwritten. Managed binaries take precedence over Homebrew's incidental
runtime dependencies and macOS system Ruby/Python.

GUI apps and launchd services do not necessarily read shell startup files. For
those, configure an explicit PATH or invoke `/opt/homebrew/bin/mise exec -- ...`;
do not assume that terminal success proves GUI tool availability. Restart apps
after setup and verify their execution environment separately.

The expanded Brewfile includes code/configuration tools, PDF/text/image/audio
utilities, secret/vulnerability scanners, cloud-storage transfer tools, and
credential CLIs. Installing these does not authenticate them, run scans, start
services, configure backups, or grant access. No Docker, full Xcode, alternate
shells, or personal shell customization is installed by default.

The Brewfile installs the ChatGPT desktop app, Spotify, and Ghostty. Open each app and
sign in separately. The old Homebrew `codex-app` cask is deprecated; use the
`chatgpt` cask for the current app. Install Amphetamine from the Mac App Store
when needed (requires App Store authentication).
Terminal, Safari, Screen Sharing, and launchd are built into macOS.

## 4. Accounts and permissions (manual)

### Tailscale CLI

Full setup includes this step. To repair only the Tailscale command:

```sh
git pull --ff-only
/bin/bash setup-tailscale.sh
```

The standalone app's official integration is **Settings > CLI integration >
Show me how > Install Now** (macOS 13+). It installs `/usr/local/bin/tailscale`.
For unattended command setup, this repository installs a small owned wrapper
at `~/.local/bin/tailscale`: it prefers the official launcher if present, otherwise
invokes `/Applications/Tailscale.app/Contents/MacOS/Tailscale` directly. Both
paths use `TAILSCALE_BE_CLI=1` to force command-line mode. The wrapper is ours;
direct app invocation and the environment variable are documented by Tailscale.
This also supports the App Store app's bundled CLI.

The step preserves unowned commands, ensures `/usr/local/bin` is on zsh's PATH,
and checks `tailscale version` in fresh login, interactive, and noninteractive
shells. It does not install a second daemon, change VPN configuration, sign in,
or restart the app. Open a fresh terminal afterward and run `tailscale status`
to check your connection privately. Version checks prove CLI execution, not
tailnet connectivity. Do not symlink the official launcher back to our wrapper.

[Official macOS CLI instructions](https://tailscale.com/docs/reference/tailscale-cli?tab=macos)

### Sign-in and permissions

- Sign in to the password manager using only the intended vault access.
- Enroll Tailscale and allow only the required remote-access paths.
- Authenticate GitHub with `gh auth login` only when private repositories or
  writes are needed. Verify with `gh api user --jq .login`.
- Sign in to Codex and any required browser/service accounts separately.
- For Linear, use the intended dedicated normal member account if separate
  attribution is desired; check its workspace role and seat implications.
- Grant only required Accessibility, Screen Recording, and automation
  permissions in macOS. Verify actual control instead of assuming installation
  grants permissions.
- Authenticate deployment tooling only when a project needs it, with narrowly
  scoped access. Never copy an existing user's credential directory or sessions.

## 5. Remote access and power (manual acceptance)

- Enable macOS Screen Sharing for only the intended local user. Use Screens 5
  on the controlling device; it does not need to be installed on this host.
- Test access over Tailscale from the controlling device. Do not expose Screen
  Sharing through a public router port forward.
- Configure on-power wake behavior and Amphetamine if closed-lid use is needed.
  Keep ventilation clear and test actual closed-lid operation on AC; installing
  a keep-awake app alone is not proof that the intended hardware setup works.
- Test screen lock/unlock, disconnect/reconnect, and restart recovery. Keep a
  local recovery path: FileVault boot unlock can prevent unattended recovery.
- Configure needed login items. Don't disable FileVault or enable automatic
  login merely to make a remote-access test pass.

## 6. Migrate work, not the old user account

1. Inventory the explicitly selected repositories and authored files privately.
2. Commit/push reviewed code where appropriate; back up local-only work and
   uncommitted changes separately. Inspect ignored files before moving them.
3. Clone repositories fresh and transfer only reviewed authored data.
4. Reinstall dependencies from project manifests; authenticate services afresh.
5. Test apps, remote access, backups, and reboot recovery on the new machine.
6. Keep the source machine intact until acceptance. Move recurring jobs one at
   a time so only one host owns each job. Do not erase or revoke source access
   as part of this bootstrap.

Do not use a whole-home copy or copy browser profiles, keychains, credential
stores, application sessions, caches, or personal dotfiles. Keep the actual
migration inventory, account identifiers, and backup destinations private.

## Maintenance

- Add tools/apps by editing Brewfile, then rerun `setup.sh`.
- Review changes with `git diff` before applying them.
- Check package declarations with `brew bundle check --file=Brewfile`.
- Upgrade deliberately during a recoverable maintenance window with
  `brew update` and `brew bundle upgrade --file=Brewfile`.
- Update runtime declarations separately, rerun `setup.sh`, and run project tests.
- Do not run automatic bundle cleanup: undeclared software is not necessarily
  unwanted. Do not restart remote-access services during unattended work.
- Back up local-only data and test restoration. Git is not a backup for ignored
  files, uncommitted changes, or application data.

## Public-repository hygiene

Only generic scripts, package names, and instructions belong here. Never commit
tokens, passwords, keys, recovery codes, email addresses, private hostnames,
account IDs, service URLs, auth exports, or real environment files. Git ignore
rules are a guardrail, not a secret scanner. Review staged content and history
before pushing; use a fresh history rather than importing personal dotfiles.

## References

- [Homebrew installation](https://docs.brew.sh/Installation)
- [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [mise runtime management](https://mise.jdx.dev/dev-tools/)
- [uv Python environments](https://docs.astral.sh/uv/pip/environments/)
- [Codex download](https://openai.com/codex/)

## Local validation (no package installs)

```sh
for script in bootstrap.sh setup.sh setup-tailscale.sh check.sh bin/tailscale lib/shell.sh tests/shell.sh tests/tailscale.sh tests/check-python.sh tests/fixtures/tailscale; do
  bash -n "$script" || break
done
ruby -c Brewfile
bash tests/shell.sh
bash tests/tailscale.sh
bash tests/check-python.sh
```

The shell test uses a temporary ZDOTDIR, never changes the real user's shell
files, and checks idempotency, preservation, and all three zsh modes. Syntax and
manifest checks do not establish fresh-machine or physical acceptance.

The Python check runs from a separate file so shell quoting cannot change its
source. Its test checks both the expected version and a deliberately wrong one.
