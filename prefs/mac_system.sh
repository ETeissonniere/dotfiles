# Prevent tampering
osascript -e 'tell application "System Preferences" to quit'

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock orientation -string right

# Fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Fast trackpad
defaults write -g com.apple.trackpad.scaling -int 4

# Safari
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# TimeMachine
echo "Disabling TimeMachine (need SUDO)"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
sudo tmutil disable

# Screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Require password immediately on sleep
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Let me change the file's extension!
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Mail
# Copy email adresses correctly
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Kill affected apps
for app in "Dock" \
	"Safari"; do
	killall "${app}" &> /dev/null
done
