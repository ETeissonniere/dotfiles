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
cask 'claude-code'
brew 'dockutil'
brew 'eza'
brew 'fd'
brew 'fzf'
brew 'gh'
cask 'ghostty'
brew 'git-lfs'
brew 'httpie'
brew 'ripgrep'
brew 'uv'
brew 'zoxide'
EOF

if [[ "$VM" != "1" ]]; then
    cat >> "$BREWFILE" <<'EOF'

brew 'container'
cask 'docker-desktop'
cask 'logi-options+'
cask 'visual-studio-code'

mas 'Flighty – Live Flight Tracker', id: 1358823008
mas 'uBlock Origin Lite', id: 6745342698
EOF

    if [[ "$NO_VIRT" != "1" ]]; then
        {
            echo ""
            echo "cask 'utm'"
        } >> "$BREWFILE"
    fi

    if [[ "$NO_SOCIALS" != "1" ]]; then
        {
            echo ""
            echo "mas 'Telegram', id: 747648890"
            echo "mas 'WhatsApp Messenger', id: 310633997"
        } >> "$BREWFILE"
    fi
fi

if [[ "$LAPTOP" == "1" ]]; then
    {
        echo ""
        echo "mas 'Tailscale', id: 1475387142"
    } >> "$BREWFILE"
fi

if [[ "$WORK_APPS" == "1" ]]; then
    {
        echo ""
        echo "mas 'Slack for Desktop', id: 803453959"
    } >> "$BREWFILE"
fi

# Run brew bundle
if [[ "$1" == "cleanup" ]]; then
    brew bundle cleanup --file="$BREWFILE" "${@:2}"
else
    brew bundle --file="$BREWFILE" "$@"
fi

# Cleanup temp file
rm -f "$BREWFILE"