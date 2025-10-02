#!/usr/bin/env bash
set -euo pipefail

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  echo "[INFO] DRY RUN: would install Docker via get.docker.com"
  exit 0
fi

if command -v docker >/dev/null 2>&1; then
  echo "[INFO] Docker already installed"
  exit 0
fi

echo "[INFO] Installing Docker"
curl -fsSL https://get.docker.com | sh
