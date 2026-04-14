# Dotfiles — Claude Code Instructions

This repo is managed by [chezmoi](https://www.chezmoi.io/). The chezmoi source tree lives under `home/` (selected via `.chezmoiroot`). Interactive toggles ask about modules at first run and live in `~/.config/chezmoi/chezmoi.toml`.

## CI

`.github/workflows/verify.yml` runs `make verify` on every push and PR. **Always run `make verify` before committing** to catch issues locally.

### Shellcheck rules
- All tracked `*.sh` files (except `modules/zsh/` and `modules/tmux/`) are linted with `shellcheck -x`
- Scripts using bash features (`read -s`, arrays, `[[ ]]`, etc.) **must** use `#!/usr/bin/env bash`, not `#!/bin/sh`
- Fix all shellcheck warnings — the CI enforces zero warnings
- chezmoi `run_*.sh.tmpl` scripts are NOT shellchecked directly (they contain Go template syntax). Keep them simple.

### Template validation
- `make verify` runs `chezmoi execute-template` against `home/.chezmoi.toml.tmpl` when chezmoi is installed locally.

### Required sources
- `.chezmoiroot`, `home/.chezmoi.toml.tmpl`, `home/dot_zshrc.tmpl`, `home/dot_gitconfig.tmpl`, and `home/.chezmoidata/packages.yaml` must exist.

## Project structure

- `home/` — chezmoi source (managed dotfiles + run_ scripts)
  - `home/.chezmoi.toml.tmpl` — init prompts (`promptBoolOnce`)
  - `home/.chezmoidata/packages.yaml` — declarative Homebrew package list
  - `home/.chezmoitemplates/bash-header` — shared shebang + sources `scripts/lib/common.sh` for log_* helpers
  - `home/.chezmoiignore` — platform-conditional exclusions
  - `home/dot_*.tmpl` / `home/dot_*` — rendered/symlinked dotfiles
  - `home/run_onchange_*` — re-run when rendered content hash changes
  - `home/run_once_*` — run once per content hash
- `modules/zsh/` — zsh fragments sourced from `~/.zshrc` at runtime (excluded from shellcheck)
- `modules/tmux/` — tmux helper scripts (sourced from `~/.tmux.conf`)
- `scripts/` — bootstrap / configure / verify / manual SSH importer

## Adding new packages

Edit `home/.chezmoidata/packages.yaml`. Bucket by platform and feature flag:
- `packages.common.brews` → every platform
- `packages.linux.brews`, `packages.darwin.base.{brews,casks,mas}`, etc.
- `packages.darwin.{desktop,virt,socials,laptop,work,personal}` are gated on the corresponding chezmoi toggle.

`chezmoi apply` will re-run `brew bundle` automatically whenever the rendered Brewfile changes.

## Adding a new toggle

1. Add a `promptBoolOnce` line in `home/.chezmoi.toml.tmpl` and expose the result under `[data]`.
2. Reference it as `.yourFlag` from any template (`run_*.sh.tmpl`, `dot_*.tmpl`, etc.).
3. Update the README table.

Existing users will be prompted the next time they `chezmoi apply`.

## Shell scripts

- Keep `scripts/` POSIX-compatible (`#!/bin/sh`) when possible; use bash shebang only when bash features are needed.
- Use `shellcheck` directives (`# shellcheck disable=SC...`) sparingly and with justification.
- chezmoi `run_*.sh.tmpl` scripts start with `{{ template "bash-header" . }}`, which sets `set -euo pipefail` and sources `scripts/lib/common.sh` for the `log_*` helpers.
