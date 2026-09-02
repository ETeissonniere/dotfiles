# Eliott's dotfiles

Managed by [chezmoi](https://www.chezmoi.io/). Module selection is interactive at first run and cached for subsequent applies.

## Quick start

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --purge-binary ETeissonniere
```

`-P`/`--purge-binary` removes the bootstrap chezmoi binary once `init --apply` finishes; the persistent binary is installed via Homebrew as part of the run.

That installs chezmoi, clones this repo into its source directory, asks a short list of yes/no questions (social apps, work apps, Git setup, etc.), and applies everything.

On a fresh Ubuntu/Debian, install `curl` first: `sudo apt install -y curl`. Everything else (build-essential, zsh, Homebrew, Docker, packages, macOS defaults) is handled by the `run_*` scripts. On macOS, the bootstrap installs the Xcode Command Line Tools before Homebrew, installs Xcode from the App Store, selects it as the active developer directory, accepts its license, and installs its required components. You may be prompted for your administrator password and must be signed in to the App Store.

## Daily operations

```sh
chezmoi update                 # pull source repo + re-apply
DOTFILES_BREW_MODE=install chezmoi update  # install missing Brew packages without a general upgrade
DOTFILES_BREW_MODE=skip chezmoi update     # apply everything except the Brew bundle
chezmoi init --prompt          # re-run toggle prompts, then `chezmoi apply`
chezmoi apply                  # apply local source-tree edits
chezmoi edit <path>            # edit a managed file and re-apply on exit
```

`dotsync` (auto-runs once/day on shell startup, or run manually) fetches the source repo, shows incoming commits, prompts, and runs `chezmoi update`. Plain `chezmoi update` keeps the existing Brew upgrade behavior. Set `DOTFILES_BREW_MODE=install` or `DOTFILES_BREW_MODE=skip` for a one-off override. Homebrew's no-upgrade mode can still upgrade dependencies when required to install a missing package.

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
| `includeSocials`      | Telegram + WhatsApp (macOS desktop only).                |
| `includeWorkApps`     | Slack, Linear, Tailscale, and KiCad (macOS only).         |
| `installCodex`        | Codex via Homebrew cask, plus `bubblewrap` apt dependency (Linux only; macOS gets it via brew). |
| `useGitea`            | Enable the post-install reminder for `scripts/post/setup_gitea.sh`. |
| `setupGit`            | Manage `~/.gitconfig` and `~/.config/git/*` (user, SSH signing, global ignore). Off for machines that don't need git. |

Plus three string prompts asked only when `setupGit` is on: `email`, `name`, and `githubUser` for git config.

Bambu Studio and OrbStack are installed on every Mac. Docker Engine is installed on every Linux machine.

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

- `scripts/post/setup_github.sh` — register `~/.ssh/id_ed25519.pub` on GitHub as both an authentication and signing key. Runs `gh auth login` itself if needed; idempotent on re-run.
- `scripts/post/setup_gitea.sh` — configure `tea` for a (self-hosted) Gitea instance using SSH-based auth. Prints copy-paste-ready values for the instance's SSH key page, waits for you to register the key, then runs `tea login add --ssh-agent-key` so no API token is ever created or stored. Prompts once for URL + username. Re-run per instance.
- `scripts/post/setup_huggingface.sh` — authenticate the Hugging Face CLI with `hf auth login`. Idempotent on re-run and does not enable Git credential storage implicitly.

## Other reminders

- On Linux, if you want passwordless sudo: `sudo visudo` and add `%sudo ALL=(ALL) NOPASSWD: ALL`.
- Configure Time Machine / Tailscale / other services manually when desired.
- On macOS, enable iCloud folder sync and set the wallpaper.
