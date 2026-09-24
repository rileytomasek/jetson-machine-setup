# Machine setup repository

This public repository configures a dedicated Apple Silicon Mac. Keep it
independent of personal dotfiles. `README.md` is the setup guide.

- Put Mac apps and host utilities in `Brewfile`, language runtimes in
  `mise.toml`, and Python's version in `.python-version`.
- Keep setup scripts safe to rerun. Preserve existing user configuration and
  refuse to replace files the setup does not own.
- Treat installation, authentication, permissions, remote access, and physical
  recovery as separate checks. A successful command does not establish that
  all of them work.
- Never commit credentials, recovery codes, personal account details, private
  infrastructure information, or machine-specific state.
- Before publishing, run the relevant syntax and tests documented in
  `README.md`, inspect the diff, and scan new content for secrets.
- Do not run `setup.sh` on a development machine merely to test a repo edit;
  it installs software and changes user configuration.
