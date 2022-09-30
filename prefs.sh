ln -sf `pwd`/gitignore ~/.gitignore
ln -sf `pwd`/zshrc ~/.zshrc

# See https://stackoverflow.com/a/27776822
case "$(uname -s)" in

     Darwin)
          # Configuration files
          ln -sf `pwd`/gitconfig ~/.gitconfig
          mkdir -p ~/.gnupg
          ln -sf `pwd`/gpg.conf ~/.gnupg/gpg.conf
          ln -sf `pwd`/gpg-agent.conf ~/.gnupg/gpg-agent.conf
          mkdir -p ~/.ssh
          ln -sf `pwd`/ssh ~/.ssh/config

          # Require password immediately on sleep
          defaults write com.apple.screensaver askForPassword -int 1
          defaults write com.apple.screensaver askForPasswordDelay -int 0

          # Properly configure git signing
          git config --global user.signingkey 8DC7D48CE7439FB0C4D1424EB1FD373857A074DD
          git config --global commit.gpgsign true

          # Firewall
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall off
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
          sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
     ;;

     Linux) # Github Codespace
          # use a correct sh system
          curl -sS https://starship.rs/install.sh > /tmp/starship.rs
          chmod +x /tmp/starship.rs
          sudo apt update
          sudo apt install -y zsh
          sudo /tmp/starship.rs --yes
	     sudo chsh -s $(which zsh) $(whoami)

          # use our gitignore file, we are not duplicating our gitconfig for Codespaces
          git config --global core.excludesfile ~/.gitignore
     ;;

esac
