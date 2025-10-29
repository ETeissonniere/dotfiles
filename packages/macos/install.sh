#!/bin/bash
# macOS package installer using Homebrew
# Generates a Brewfile based on environment variables and installs packages
#
# Environment variables:
#   VM=1       - Skip desktop apps (for VMs)
#   NO_VIRT=1  - Skip virtualization tools
#   LAPTOP=1   - Include laptop-specific tools
#
# Usage:
#   ./install.sh          # Install packages
#   ./install.sh cleanup  # Remove packages not in current config

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/.Brewfile.tmp"

# Generate Brewfile based on environment
cat > "$BREWFILE" <<'EOF'
cask 'appcleaner'
brew 'dockutil'
brew 'eza'
brew 'fd'
brew 'fzf'
brew 'gh'
brew 'git-lfs'
brew 'httpie'
brew 'ripgrep'
brew 'uv'
brew 'zoxide'
EOF

if [[ "$VM" != "1" ]]; then
    cat >> "$BREWFILE" <<'EOF'

cask 'container'
cask 'docker-desktop'
cask 'logi-options+'
cask 'visual-studio-code'

mas 'Flighty – Live Flight Tracker', id: 1358823008
mas 'Telegram', id: 747648890
mas 'uBlock Origin Lite', id: 6745342698
mas 'WhatsApp Messenger', id: 310633997
EOF

    if [[ "$NO_VIRT" != "1" ]]; then
        echo "" >> "$BREWFILE"
        echo "cask 'utm'" >> "$BREWFILE"
    fi
fi

if [[ "$LAPTOP" == "1" ]]; then
    echo "" >> "$BREWFILE"
    echo "mas 'Tailscale', id: 1475387142" >> "$BREWFILE"
fi

# Run brew bundle
if [[ "$1" == "cleanup" ]]; then
    brew bundle cleanup --file="$BREWFILE" "${@:2}"
else
    brew bundle --file="$BREWFILE" "$@"
fi

# Cleanup temp file
rm -f "$BREWFILE"