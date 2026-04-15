#!/usr/bin/env bash
# Manual helper: import an existing SSH key into ~/.ssh. Not part of the
# chezmoi apply flow — use this when bringing a key over from another
# machine instead of generating a fresh one via the run_once_after script.
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") --from <path> [--label <name>]

  --from     Path to the existing private key (public key at <path>.pub)
  --label    Destination filename under ~/.ssh (default: id_ed25519)
EOF
}

SOURCE=""
LABEL="id_ed25519"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)     SOURCE="$2"; shift 2 ;;
    --label)    LABEL="$2";  shift 2 ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

[[ -n "$SOURCE"      ]] || { usage >&2; exit 1; }
[[ -f "$SOURCE"      ]] || { echo "Missing $SOURCE"      >&2; exit 1; }
[[ -f "$SOURCE.pub"  ]] || { echo "Missing $SOURCE.pub"  >&2; exit 1; }

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

target="$HOME/.ssh/$LABEL"
[[ ! -e "$target" && ! -e "$target.pub" ]] || { echo "$target already exists; refusing to overwrite" >&2; exit 1; }

cp "$SOURCE"     "$target"
cp "$SOURCE.pub" "$target.pub"
chmod 600 "$target"
chmod 644 "$target.pub"
echo "==> Imported key to $target"
