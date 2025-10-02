# Eliott's dotfiles

These dotfiles configure macOS workstations and Linux servers with a consistent toolchain and shell experience. Use at your own risk.

## Quick start

```sh
# Install or update the dotfiles repo, then run the bootstrap sequence
curl -fsSL https://git.io/eliott_dot_sh | sh

# or, if the repo is already cloned
make bootstrap
```

Set `DRY_RUN=1` to preview actions without making changes:

```sh
DRY_RUN=1 make bootstrap
```

## Targets

- `make bootstrap` – detect the platform, install packages, and deploy configuration files.
- `make packages` – install only the package dependencies for the current platform.
- `make link` – (re)link shell, git, and SSH config without touching packages.
- `make verify` – run basic linting and structure checks.

## Layout

```
config/           # Source dotfiles (git, ssh, zsh) grouped by domain
modules/zsh/      # Shared zsh fragments with platform overrides
packages/         # Package manifests per platform + post-install hooks
scripts/          # Bootstrap helpers, library code, verification, SSH tooling
```

## Post-install reminders

- Generate/import SSH keys with `scripts/ssh/import_key.sh` (update `config/git/allowed_signers` as needed).
- Run `gh auth login -p ssh` to authenticate GitHub.
- Configure Time Machine / Tailscale / other services manually when desired.
