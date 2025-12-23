# Eliott's dotfiles

These dotfiles configure macOS workstations and Linux servers with a consistent toolchain and shell experience. Use at your own risk.

## Quick start

```sh
git clone https://github.com/ETeissonniere/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
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

## macOS package toggles

The macOS package installer and configuration scripts react to a few environment variables so you can tailor installs:

- `VM=1` – skip GUI-heavy tools (VS Code, Docker Desktop, etc.), don't add them to the dock, and keep the dock visible instead of auto-hiding.
- `NO_VIRT=1` – skip UTM virtualization tooling.
- `NO_SOCIALS=1` – skip social apps like WhatsApp and Telegram.
- `LAPTOP=1` – include laptop-only utilities such as Tailscale.
- `WORK_APPS=1` – include work only apps like Slack.
- `PERSONAL_APPS=1` – include personal apps like Bambu Studio.

## Post-install reminders

- Generate/import SSH keys with `scripts/ssh/import_key.sh` (update `config/git/allowed_signers` as needed).
- Run `gh auth login -p ssh` to authenticate GitHub.
- Configure Time Machine / Tailscale / other services manually when desired.
- On Mac, enable iCloud folder sync if desired.
- Set wallpaper.
- If desired, switch the dotfiles remote to SSH `git remote remove origin && git remote add origin git@github.com:ETeissonniere/dotfiles.git`
