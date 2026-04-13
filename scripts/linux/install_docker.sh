#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would install Docker"
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  log_info "Installing Docker via official install script"
  curl -fsSL https://get.docker.com | sudo sh
  log_info "Docker installed: $(docker --version)"
else
  log_info "Docker already installed: $(docker --version)"
fi

# Ensure current user is in the docker group
if ! groups "$(whoami)" | grep -q docker; then
  sudo usermod -aG docker "$(whoami)"
  log_info "Added $(whoami) to docker group (re-login required)"
fi
