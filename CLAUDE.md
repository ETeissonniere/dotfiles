# Dotfiles — Claude Code Instructions

## CI

This project has a CI workflow (`.github/workflows/verify.yml`) that runs `make verify` on every push and PR. **Always run `make verify` before committing** to catch issues locally.

### Shellcheck rules
- All tracked `*.sh` files (except `modules/zsh/`) are linted with `shellcheck -x`
- Scripts using bash features (`read -s`, arrays, `[[ ]]`, etc.) **must** use `#!/usr/bin/env bash`, not `#!/bin/sh`
- Fix all shellcheck warnings — the CI enforces zero warnings

### Symlink targets
- `config/zsh/zshrc` must exist — CI validates this

## Project structure

- `config/` — dotfile sources grouped by tool (zsh, git, starship, tmux, etc.)
- `modules/zsh/` — shared zsh modules (excluded from shellcheck)
- `scripts/` — bootstrap, config deployment, and verification scripts
- `packages/` — package manifests (Brewfile, apt.txt)

## Shell scripts

- Keep scripts POSIX-compatible (`#!/bin/sh`) when possible; use bash shebang only when bash features are needed
- Use `shellcheck` directives (`# shellcheck disable=SC...`) sparingly and with justification
