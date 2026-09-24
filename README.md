# Jetson machine setup

Lightweight setup for a dedicated Apple Silicon Mac. Independent of personal
dotfiles: Homebrew owns apps/utilities, mise owns Node/Bun, and uv owns Python
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

## 3. Install software

```sh
mkdir -p ~/jetson-workspace
git clone https://github.com/rileytomasek/jetson-machine-setup.git \
  ~/jetson-workspace/machine-setup
cd ~/jetson-workspace/machine-setup
brew bundle --file=Brewfile --no-upgrade
less mise.toml
mise trust
mise install
mise exec -- node --version
mise exec -- bun --version
```

Cloning this public repository requires no authentication. Reuse an existing
clone instead of repeating `git clone`. Homebrew installation can be rerun;
`--no-upgrade` avoids opportunistic upgrades but does not lock package versions.

The runtime configuration applies within this repository. To use the same
baseline throughout the workspace without shell activation, explicitly set it:

```sh
mise use --global node@24 bun@1
mise exec -- node --version
```

These are major-version tracks, not exact pins. Projects should declare their
own tested versions. Use `mise exec -- <command>` in terminal/background tasks;
GUI apps do not necessarily inherit a terminal's PATH. Use `uv venv --python 3.13`
inside a Python project when needed; don't install competing Python managers.
No Docker, full Xcode, alternate shells, or extra runtimes by default.

Install the current Codex desktop app from its official distribution. The old
Homebrew `codex-app` cask is deprecated; it is intentionally not included here.
Install Amphetamine from the Mac App Store when needed (requires App Store
authentication). Optional music app: `brew install --cask spotify`.
Terminal, Safari, Screen Sharing, and launchd are built into macOS.

## 4. Accounts and permissions (manual)

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

- Add tools/apps by editing Brewfile, then rerun the bundle command.
- Review changes with `git diff` before applying them.
- Check package declarations with `brew bundle check --file=Brewfile`.
- Upgrade deliberately during a recoverable maintenance window with
  `brew update` and `brew bundle upgrade --file=Brewfile`.
- Update runtime declarations separately and rerun project tests.
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

Syntax and manifest checks do not establish fresh-machine or physical acceptance.
