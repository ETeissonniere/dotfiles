case "$(uname -s)" in
     Darwin)
          # keep going
     ;;

     *)
          echo "Unsupported OS"
          exit 1
     ;;
esac

EXPECTED_USER="eliottteissonniere"
CURRENT_USER="${SUDO_USER:-$(id -un)}"
if [ "$CURRENT_USER" != "$EXPECTED_USER" ]; then
     echo "This setup expects macOS user '$EXPECTED_USER', but detected '$CURRENT_USER'." >&2
     echo "Update the hardcoded paths in gitconfig or change the login before rerunning." >&2
     exit 1
fi

DOTFILES_ROOT="$(cd "$(dirname "$0")" && pwd)"

link_dotfile() {
     link_source="$DOTFILES_ROOT/$1"
     link_target="$2"

     if [ ! -e "$link_source" ]; then
          echo "Missing source $link_source; skipping." >&2
          return
     fi

     if [ -L "$link_target" ]; then
          current_target="$(readlink "$link_target")"
          if [ "$current_target" = "$link_source" ]; then
               echo "✔ already linked: $link_target"
               return
          fi
     fi

     if [ -e "$link_target" ] && [ ! -L "$link_target" ]; then
          echo "Replacing existing $link_target with symlink."
     fi

     ln -snf "$link_source" "$link_target"
     echo "→ linked $link_target -> $link_source"
}

configure_links() {
     mkdir -p "$HOME/.ssh"
     link_dotfile "ssh" "$HOME/.ssh/config"
     link_dotfile "zshrc" "$HOME/.zshrc"
     # linking relies on username guard above
     link_dotfile "gitconfig" "$HOME/.gitconfig"
}

configure_macos_defaults() {
     echo "### Please enter the computer name:"
     read -r computerName

     if [ -n "$computerName" ]; then
          sudo scutil --set ComputerName "$computerName"
          sudo scutil --set HostName "$computerName"
          sudo scutil --set LocalHostName "$computerName"
          sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computerName"
     else
          echo "Skipping computer name configuration (empty input)."
     fi

     defaults write com.apple.screensaver askForPassword -int 1
     defaults write com.apple.screensaver askForPasswordDelay -int 0

     defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
     defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
     defaults write NSGlobalDomain AppleMetricUnits -bool true
     defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

     defaults write NSGlobalDomain KeyRepeat -int 2
     defaults write NSGlobalDomain InitialKeyRepeat -int 30
     defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
     defaults write NSGlobalDomain com.apple.mouse.scaling -float 3

     defaults write com.apple.dock autohide -bool YES
     defaults write com.apple.dock tilesize -integer 64
     killall Dock >/dev/null 2>&1 || true

     defaults write com.apple.Terminal "Default Window Settings" -string "Clear Dark"
}

configure_homebrew() {
     if ! command -v brew >/dev/null 2>&1; then
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
     fi

     brew bundle --file "$DOTFILES_ROOT/Brewfile"
}

configure_dock() {
     if command -v dockutil >/dev/null 2>&1; then
          "$DOTFILES_ROOT/mac_dock.sh"
     fi
}

maybe_configure_macos_defaults() {
     printf "Apply macOS defaults and system settings now? [y/N]: "
     read -r response

     case "$response" in
          [Yy]*)
               configure_macos_defaults
               ;;
          *)
               echo "Skipping macOS defaults."
               ;;
     esac
}

print_reminders() {
     echo "#######################################################"
     echo "# 🔥 Battlestation ready - remaining actions#"
     echo "#######################################################"
     echo ""
     echo "→ Install SSH key"
     echo "→ Run \`gh auth login -p ssh\`"
     echo "→ Setup TimeMachine"
     echo "→ Login to Tailscale if desired"
}

configure_links
maybe_configure_macos_defaults
configure_homebrew
configure_dock
print_reminders
