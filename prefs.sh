ln -sf `pwd`/condarc ~/.condarc
ln -sf `pwd`/zshrc ~/.zshrc
cp -f `pwd`/gitconfig ~/.gitconfig

git config --global gpg.ssh.allowedSignersFile `pwd`/allowed_signers
git config --global core.excludesfile `pwd`/gitignore

# See https://stackoverflow.com/a/27776822
case "$(uname -s)" in

     Darwin)
          # Configuration files
          mkdir -p ~/.ssh
          ln -sf `pwd`/ssh.macos ~/.ssh/config

          # Finish git config using 1Password
          git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

          echo "### Please enter the computer name:"
          read computerName

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

          # Firewall
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

          # Packages

          # Only run the below if brew is not installed
          if ! command -v brew &> /dev/null
          then
               /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          fi
          brew bundle

          # Reminders / TODOs
          echo "#######################################################"
          echo "# 🔥 Battlestation ready - remaining actions          #"
          echo "#######################################################"
          echo ""
          echo "→ Install SSH key"
          echo "→ Run \`gh auth login -p ssh\`"
          echo "→ Setup TimeMachine"
     ;;

     Linux)
          mkdir -p ~/.ssh
          ln -sf `pwd`/ssh.linux ~/.ssh/config

          ln -sf `pwd`/configs/hypr ~/.config/hypr
          ln -sf `pwd`/configs/waybar ~/.config/waybar
          ln -sf `pwd`/configs/rofi ~/.config/rofi
          ln -sf `pwd`/configs/systemd ~/.config/systemd
          ln -sf `pwd`/configs/swaync ~/.config/swaync
          ln -sf `pwd`/configs/ghostty ~/.config/ghostty

          # if pacman is installed, we run on Arch and thus install
          # our local packages
          # Note that this really only installs useful packages and
          # in no way sets up a full arch distro
          if [ -x "$(command -v pacman)" ]; then
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm $(cat arch-packages) $(cat arch-gui-packages)
          fi

          # if yay is installed, install AUR packages
          if [ -x "$(command -v yay)" ]; then
            yay -S --noconfirm $(cat aur-packages)
          fi
          
          # switch to ZSH if installed
          if [ -x "$(command -v zsh)" ]; then
            chsh -s $(which zsh)
          fi
          
          # Enable a couple services for desktop use, can be skipped on pure servers
          systemctl enable --now bluetooth || echo "BLE not installed"

          # Enable SSH agent service
          systemctl enable --now --user ssh-agent.service
     ;;
esac
