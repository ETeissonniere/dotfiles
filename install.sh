#! /bin/sh

osascript -e 'tell application "System Preferences" to quit'

chsh -s $(which zsh)

xcode-select --install || echo "Developer tools already installed"

# Install XCODE
# Install iWork and iMovies
# Install GPG
# Install docker

# Max mouse sensitivity
#defaults write -g com.apple.trackpad.scaling 3

# Ask passwords immediately (security settings)

# Reset .ssh
# Reset .gpg

# Wallpaper
# Profile picture

# Reconnect accounts

# Enable filevault
#sudo fdesetup enable

# Firmware password
#sudo firmwarepasswd -setpasswd -setmode command

# Enable firewall
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
#sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingopt throttled

# Disable guest user
#sudo sysadminctl -guestAccount off

# Authorize non App Stores apps
# Don't ask password for free apps

# iCloud
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # I care about my privacy
# Enable FindMyMac

# Disable dashboard (why does it even exists?)
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dock dashboard-in-overlay -bool true

# Safari
#defaults write com.apple.Safari UniversalSearchEnabled -bool false
#defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
#defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Terminal
defaults write com.apple.terminal SecureKeyboardEntry -bool true
#defaults write com.apple.Terminal.plist "Default Window Settings" "Pro"
#defaults write com.apple.Terminal.plist "Startup Window Settings" "Pro"

# Metadata
#defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
#defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

#defaults write com.apple.CrashReporter DialogType -string "none"

# OH MY ZSH (disable auto update)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cp -rf ./vim ~/.vim
cp -f ./vimrc ~/.vimrc
cp -f ./gitconfig ~/.gitconfig
cp -f ./gitignore ~/.gitignore
cp -f ./zshrc ~/.zshrc
