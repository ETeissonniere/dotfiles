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

# TimeMachine
echo "Disabling TimeMachine (need SUDO)"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
sudo tmutil disable

# Kill affected apps
for app in "Dock" \
	"Safari"; do
	killall "${app}" &> /dev/null
done
