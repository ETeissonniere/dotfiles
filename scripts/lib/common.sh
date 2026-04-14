#!/usr/bin/env bash
# Shared logging helpers. Sourced by scripts/*.sh and by chezmoi run_*.sh.tmpl
# (via home/.chezmoitemplates/bash-header).

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export DOTFILES_ROOT

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  _C_INFO=$'\033[1;34m'; _C_WARN=$'\033[1;33m'; _C_ERR=$'\033[1;31m'; _C_OFF=$'\033[0m'
else
  _C_INFO=''; _C_WARN=''; _C_ERR=''; _C_OFF=''
fi

log_info()  { printf '%s[INFO]%s %s\n'  "$_C_INFO" "$_C_OFF" "$*"; }
log_warn()  { printf '%s[WARN]%s %s\n'  "$_C_WARN" "$_C_OFF" "$*" >&2; }
log_error() { printf '%s[ERROR]%s %s\n' "$_C_ERR"  "$_C_OFF" "$*" >&2; }
