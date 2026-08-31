#!/usr/bin/env bash
# Authenticate the Hugging Face CLI. Idempotent on re-run.
set -euo pipefail

command -v hf >/dev/null 2>&1 || { echo "Hugging Face CLI not installed" >&2; exit 1; }

if hf auth whoami >/dev/null 2>&1; then
  echo "==> Hugging Face CLI is already authenticated"
  exit 0
fi

echo "==> Authenticating with Hugging Face"
hf auth login
