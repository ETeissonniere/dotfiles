#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=scripts/lib/os.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/os.sh"

export_platform

if [[ "$DOTFILES_PLATFORM" != "macos" ]]; then
  log_warn "macOS defaults script invoked on non-macOS platform; skipping"
  exit 0
fi

if [[ "${DRY_RUN:-0}" == "1" ]]; then
  log_info "DRY RUN: would configure macOS defaults"
  exit 0
fi

if [[ "${SKIP_RENAMING:-0}" == "1" ]]; then
  log_info "Skipping computer name configuration (SKIP_RENAMING=1)"
else
  read -r -p "Computer name (blank to skip renaming): " computer_name
  if [[ -n "$computer_name" ]]; then
    sudo scutil --set ComputerName "$computer_name"
    sudo scutil --set HostName "$computer_name"
    sudo scutil --set LocalHostName "$computer_name"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"
    log_info "Set computer/host names to $computer_name"
  else
    log_info "Skipping computer name configuration"
  fi
fi

log_info "Editing system settings"

# Don't be a madman and start the week on monday
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2

# Security & input settings
sudo defaults write com.apple.screensaver askForPassword -int 1
sudo defaults write com.apple.screensaver askForPasswordDelay -int 0

# Locale & measurement units
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

# Keyboard & pointing devices
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 30
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# Screenshots - Set Cmd+Shift+S to copy screenshot selection to clipboard (requires logout)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 '<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>115</integer><integer>1</integer><integer>1179648</integer></array></dict></dict>'

# Dock
if [ "${VM:-0}" != "1" ]; then
    defaults write com.apple.dock autohide -bool true
fi
defaults write com.apple.dock tilesize -int 64
killall Dock >/dev/null 2>&1 || true

# Finder
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowRecentTags -bool false
killall Finder

log_info "Editing Finder folders"
mkdir -p ~/Developer

# Open in home directory
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/$(whoami)/"

#Turn on iCloud Drive desktop/documents
defaults write com.apple.finder FXICloudDriveDesktop -bool true
defaults write com.apple.finder FXICloudDriveDocuments -bool true

# Sidebar settings
defaults write com.apple.finder ShowRecentTags -bool no

osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

log_info "Editing TimeMachine exclusions"
tmutil addexclusion ~/Developer
tmutil addexclusion ~/Downloads

log_info "macOS defaults configured"
