case "$(uname -s)" in
     Darwin)
          # keep going
     ;;

     *)
          echo "Unsupported OS"
          exit 1
     ;;
esac

mkdir -p ~/.ssh
ln -sf `pwd`/ssh ~/.ssh/config
ln -sf `pwd`/zshrc ~/.zshrc
# this assumes username is "eliottteissonniere"
ln -sf `pwd`/gitconfig ~/.gitconfig

echo "### Please enter the computer name:"
read computerName

# set computer name
sudo scutil --set ComputerName $computerName
sudo scutil --set HostName $computerName
sudo scutil --set LocalHostName $computerName
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $computerName

# Require password immediately on sleep
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Use proper units
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

# ⚡ fast keyboard, trackpad, and mouse
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 30
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3

# non obtrusive dock
defaults write com.apple.dock autohide -bool YES
defaults write com.apple.dock tilesize -integer 64
killall Dock

# set Terminal theme
defaults write com.apple.Terminal "Default Window Settings" -string "Clear Dark"

# Only run the below if brew is not installed
if ! command -v brew &> /dev/null
then
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle

# Only run below if dockutil is installed
if command -v dockutil &> /dev/null
then
     ./mac_dock.sh
fi

# Only run if NVM is installed
if command -v nvm &> /dev/null
then
     echo "configuring node..."
     nvm install --lts
     nvm use --lts

     echo "installing claude code..."
     npm install -g @anthropic-ai/claude-code
fi

# Reminders / TODOs
echo "#######################################################"
echo "# 🔥 Battlestation ready - remaining actions#"
echo "#######################################################"
echo ""
echo "→ Install SSH key"
echo "→ Run \`gh auth login -p ssh\`"
echo "→ Setup TimeMachine"