#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/../../../scripts/lib/common.sh"

DRY_RUN="${DRY_RUN:-0}"
NVM_VERSION="v0.40.3"
NVM_DIR="$HOME/.nvm"

if [[ "$DRY_RUN" == "1" ]]; then
  log_info "DRY RUN: would install nvm, Node.js LTS, and @openai/codex"
  exit 0
fi

if command -v codex >/dev/null 2>&1; then
  log_info "Codex already installed"
  exit 0
fi

install_nvm() {
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    return
  fi

  log_info "Installing nvm ${NVM_VERSION}"
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
}

load_nvm() {
  export NVM_DIR
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
  else
    log_error "nvm installation not found in $NVM_DIR"
    exit 1
  fi

  if [[ -s "$NVM_DIR/bash_completion" ]]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/bash_completion"
  fi
}

install_node() {
  install_nvm
  load_nvm

  log_info "Installing latest Node.js"
  nvm install node >/dev/null
  nvm use node >/dev/null

  log_info "Node.js installation complete"
}

install_codex() {
  install_node

  log_info "Installing @openai/codex"
  npm install -g @openai/codex

  log_info "Codex installation complete"
}

install_codex
