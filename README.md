# Eliott's dotfiles

These dotfiles configure macOS workstations and Linux servers with a consistent toolchain and shell experience. They are managed by [chezmoi](https://www.chezmoi.io/); module selection is interactive at first run and cached for subsequent applies.

## Quick start

```sh
git clone https://github.com/ETeissonniere/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make bootstrap
```

`make bootstrap` installs chezmoi, asks a short list of yes/no questions about which modules you want (desktop apps, work apps, Docker, etc.), and applies everything. Answers are cached in `~/.config/chezmoi/chezmoi.toml`.

To preview without applying anything:

```sh
DRY_RUN=1 make bootstrap
```

## Targets

- `make bootstrap` – install chezmoi, prompt for module toggles, apply.
- `make apply` – re-apply after pulling updates (`chezmoi apply`).
- `make configure` – re-run the toggle prompts (your previous answers become defaults), then apply.
- `make verify` – shellcheck + template validation (used by CI).

## Module toggles

When you run `make bootstrap` or `make configure`, chezmoi asks:

| Toggle              | Effect                                                   |
|---------------------|----------------------------------------------------------|
| `isDesktop`         | Enables desktop GUI apps, Docker Desktop, Zed, macOS dock auto-hide. Turn off for VMs and headless servers. |
| `includeVirt`       | UTM virtualization (macOS desktop only).                 |
| `includeSocials`    | Telegram + WhatsApp (macOS desktop only).                |
| `isLaptop`          | Tailscale (macOS only).                                  |
| `includeWorkApps`   | Slack (macOS only).                                      |
| `includePersonalApps` | Bambu Studio, KiCad (macOS only).                      |
| `installDocker`     | Docker via get.docker.com (Linux only).                  |

Answers live in `~/.config/chezmoi/chezmoi.toml`. Edit it directly or run `make configure` to re-prompt.

## Layout

```
.chezmoiroot              # points chezmoi at ./home
home/
  .chezmoi.toml.tmpl      # init prompts that populate chezmoi data
  .chezmoidata/           # declarative data (packages.yaml)
  .chezmoitemplates/      # shared template partials
  .chezmoiignore          # platform-conditional exclusions
  dot_*                   # → $HOME/.* after apply
  private_dot_ssh/        # → $HOME/.ssh (mode 700)
  run_onchange_*          # re-run when rendered content changes
  run_once_*              # run once per hash
modules/                  # runtime zsh/tmux modules sourced by rendered configs
scripts/                  # bootstrap, configure, verify helpers
```

## How updates work

- `dotsync` (zsh function, auto-runs once/day on shell startup) fetches `origin/master`, shows new commits, prompts to apply, and runs `chezmoi apply`.
- Adding a package to `home/.chezmoidata/packages.yaml` changes the rendered Brewfile's hash, so the next `chezmoi apply` re-runs `brew bundle`.
- Adding a new toggle to `home/.chezmoi.toml.tmpl` triggers a one-time prompt on the next `chezmoi apply`.

## Post-install reminders

- Import an existing SSH key instead of generating a new one: `scripts/ssh/import_key.sh --from /path/to/key`. Update `home/dot_config/git/allowed_signers` as needed.
- Run `gh auth login -p ssh` to authenticate GitHub (enables the `run_once_after_60-ssh-setup` script to register your key).
- Configure Time Machine / Tailscale / other services manually when desired.
- On macOS, enable iCloud folder sync and set the wallpaper.
- If desired, switch the dotfiles remote to SSH: `git remote set-url origin git@github.com:ETeissonniere/dotfiles.git`.
