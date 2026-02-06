#!/usr/bin/env bash
set -euo pipefail

log_info()  { printf '\033[1;34m[INFO]\033[0m %s\n' "$1"; }
log_warn()  { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
log_error() { printf '\033[1;31m[ERROR]\033[0m %s\n' "$1"; }
ensure_dir() { mkdir -p "$1"; }

usage() {
  cat <<USAGE
Usage: $(basename "$0") [--from <path>] [--label <name>]

Options:
  --from   Path to an existing SSH key (without extension). Copies both the
           private and public key to ~/.ssh.
  --label  Alternate file name to use instead of id_rsa.
  --help   Show this message.
USAGE
}

SOURCE=""
LABEL="id_rsa"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)
      SOURCE="$2"
      shift 2
      ;;
    --label)
      LABEL="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      log_error "Unknown option $1"
      usage
      exit 1
      ;;
  esac
done

ensure_dir "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

target_private="$HOME/.ssh/${LABEL}"
target_public="$target_private.pub"

if [[ -n "$SOURCE" ]]; then
  if [[ ! -f "$SOURCE" ]]; then
    log_error "Missing source key $SOURCE"
    exit 1
  fi
  if [[ ! -f "${SOURCE}.pub" ]]; then
    log_error "Missing public key ${SOURCE}.pub"
    exit 1
  fi

  if [[ -f "$target_private" || -f "$target_public" ]]; then
    log_warn "Target files already exist; refusing to overwrite"
    exit 1
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_info "DRY RUN: would copy $SOURCE to $target_private"
  else
    cp "$SOURCE" "$target_private"
    cp "${SOURCE}.pub" "$target_public"
    chmod 600 "$target_private"
    chmod 644 "$target_public"
    log_info "Imported key to $target_private"
  fi
else
  read -r -p "Existing private key path (leave blank to abort): " manual_path
  if [[ -z "$manual_path" ]]; then
    log_warn "No key imported"
    exit 0
  fi
  "$0" --from "$manual_path" --label "$LABEL"
  exit $?
fi
