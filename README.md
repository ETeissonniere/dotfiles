# Eliott's dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). Module selection is interactive at first run and cached for subsequent applies.

## Quick start

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply ETeissonniere
```

The `/lb` variant installs chezmoi to `~/.local/bin` (which the rendered zsh config puts on PATH for you).

That installs chezmoi, clones this repo into its source directory, asks a short list of yes/no questions (desktop? Docker? social apps?…), and applies everything.

On a fresh Ubuntu/Debian, install `curl` first: `sudo apt install -y curl`. Everything else (build-essential, zsh, Homebrew, Docker, packages, macOS defaults) is handled by the `run_*` scripts.

## Daily operations

```sh
chezmoi update                 # pull source repo + re-apply
chezmoi init --prompt          # re-run toggle prompts, then `chezmoi apply`
chezmoi apply                  # apply local source-tree edits
chezmoi edit <path>            # edit a managed file and re-apply on exit
```

`dotsync` (auto-runs once/day on shell startup, or run manually) fetches the source repo, shows incoming commits, prompts, and runs `chezmoi update`.

### Optional: auto-commit/push changes to the repo

Add this to `~/.config/chezmoi/chezmoi.toml` if you'd like local edits to be pushed automatically:

```toml
[git]
    autoCommit = true
    autoPush = true
```

See the [chezmoi docs](https://www.chezmoi.io/user-guide/daily-operations/) for details.

## Module toggles

Asked at init and cached; re-prompt via `chezmoi init --prompt`.

| Toggle                | Effect                                                   |
|-----------------------|----------------------------------------------------------|
| `isDesktop`           | Enables desktop GUI apps, Docker Desktop, Zed, macOS dock auto-hide. Off for VMs/servers. |
| `includeVirt`         | UTM virtualization (macOS desktop only).                 |
| `includeSocials`      | Telegram + WhatsApp (macOS desktop only).                |
| `isLaptop`            | Tailscale (macOS only).                                  |
| `includeWorkApps`     | Slack (macOS only).                                      |
| `includePersonalApps` | Bambu Studio, KiCad (macOS only).                        |
| `installDocker`       | Docker via get.docker.com (Linux only).                  |
| `installClaudeCode`   | Claude Code via `claude.ai/install.sh` (Linux only; macOS gets it via brew). |

Plus two string prompts: `email` and `name` for git config.

## Layout

```
.chezmoiroot                       # points chezmoi at ./home
home/
  .chezmoi.toml.tmpl               # init prompts
  .chezmoidata/packages.yaml       # declarative Homebrew manifest
  .chezmoiignore                   # platform-conditional exclusions
  dot_*                            # → $HOME/.* after apply
  private_dot_ssh/                 # → $HOME/.ssh (mode 700)
  run_onchange_*                   # re-run when rendered content changes
  run_once_*                       # run once per content hash
modules/                           # runtime zsh/tmux helpers
scripts/post/                      # post-install helpers (user-invoked)
```

## Post-install helpers

Scripts under `scripts/post/` are one-shot tasks the user runs manually (chezmoi can't sensibly drive interactive OAuth-style flows). A checker at the end of every `chezmoi apply` prints a reminder for each pending item until it's done.

- `scripts/post/register_github_key.sh` — registers `~/.ssh/id_ed25519.pub` on GitHub as both an authentication and signing key. Runs `gh auth login` itself if needed; idempotent on re-run.
- `scripts/post/setup_gitea.sh` — configure `tea` for a (self-hosted) Gitea instance and register `~/.ssh/id_ed25519.pub` on it via the Gitea REST API. Prompts once for URL + username + token. Re-run per instance.

## Other reminders

- On Linux, if you want passwordless sudo: `sudo visudo` and add `%sudo ALL=(ALL) NOPASSWD: ALL`.
- Configure Time Machine / Tailscale / other services manually when desired.
- On macOS, enable iCloud folder sync and set the wallpaper.
