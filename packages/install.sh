#!/bin/bash
# Cross-platform Homebrew package installer
# Generates a Brewfile based on platform and environment variables, then runs brew bundle
#
# Environment variables (macOS only):
#   VM=1            - Skip desktop apps (for VMs)
#   NO_VIRT=1       - Skip virtualization tools
#   NO_SOCIALS=1    - Skip social apps
#   LAPTOP=1        - Include laptop-specific tools
#   WORK_APPS=1     - Include work apps
#   PERSONAL_APPS=1 - Include personal apps (Bambu Studio, KiCad)
#
# Usage:
#   ./install.sh          # Install packages
#   ./install.sh cleanup  # Remove packages not in current config

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/.Brewfile.tmp"

PLATFORM="$(uname -s)"

# --- Common CLI tools (both platforms) ---
cat > "$BREWFILE" <<'EOF'
brew 'eza'
brew 'fd'
brew 'fzf'
brew 'gh'
brew 'git-lfs'
brew 'glab'
brew 'httpie'
brew 'ripgrep'
brew 'tea'
brew 'uv'
brew 'zoxide'
EOF

# --- Linux-only brews ---
if [[ "$PLATFORM" == "Linux" ]]; then
    cat >> "$BREWFILE" <<'EOF'

brew 'btop'
brew 'vim'
EOF
fi

# --- macOS-only packages ---
if [[ "$PLATFORM" == "Darwin" ]]; then
    cat >> "$BREWFILE" <<'EOF'

cask 'appcleaner'
cask 'claude'
cask 'claude-code'
brew 'dockutil'
cask 'ghostty'
cask 'logseq'
EOF

    if [[ "${VM:-}" != "1" ]]; then
        cat >> "$BREWFILE" <<'EOF'

brew 'container'
cask 'docker-desktop'
cask 'logi-options+'
cask 'zed'

mas 'Flighty – Live Flight Tracker', id: 1358823008
mas 'Numbers', id: 409203825
mas 'Pages', id: 409201541
mas 'uBlock Origin Lite', id: 6745342698
EOF

        if [[ "${NO_VIRT:-}" != "1" ]]; then
            {
                echo ""
                echo "cask 'utm'"
            } >> "$BREWFILE"
        fi

        if [[ "${NO_SOCIALS:-}" != "1" ]]; then
            {
                echo ""
                echo "mas 'Telegram', id: 747648890"
                echo "mas 'WhatsApp Messenger', id: 310633997"
            } >> "$BREWFILE"
        fi
    fi

    if [[ "${LAPTOP:-}" == "1" ]]; then
        {
            echo ""
            echo "mas 'Tailscale', id: 1475387142"
        } >> "$BREWFILE"
    fi

    if [[ "${WORK_APPS:-}" == "1" ]]; then
        {
            echo ""
            echo "cask 'google-chrome'"
            echo "mas 'Slack for Desktop', id: 803453959"
        } >> "$BREWFILE"
    fi

    if [[ "${PERSONAL_APPS:-}" == "1" ]]; then
        {
            echo ""
            echo "cask 'bambu-studio'"
            echo "cask 'kicad'"
        } >> "$BREWFILE"
    fi
fi

# Run brew bundle
if [[ "${1:-}" == "cleanup" ]]; then
    brew bundle cleanup --file="$BREWFILE" "${@:2}"
else
    brew bundle --file="$BREWFILE" "$@"
fi

# Cleanup temp file
rm -f "$BREWFILE"
