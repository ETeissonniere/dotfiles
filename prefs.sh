ln -sf `pwd`/zshrc ~/.zshrc

# See https://stackoverflow.com/a/27776822
case "$(uname -s)" in

     Darwin)
          # Configuration files
          cp -f `pwd`/gitconfig ~/.gitconfig
          mkdir -p ~/.ssh
          ln -sf `pwd`/ssh ~/.ssh/config

          # Require password immediately on sleep
          defaults write com.apple.screensaver askForPassword -int 1
          defaults write com.apple.screensaver askForPasswordDelay -int 0

          # Properly configure git signing via 1pass
          git config --global user.signingkey "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3NGKCRfi2gh8mHF8u0tFFcv/H0BQyY8KHrO5OXsusUTnI0ll97Y238wt8wqo+hoea+Hzu67uT7VI58YlqMhxY52YhqlX1k5EAKhNRwvabnC11wR8cI6/Jo+W8b6o8Sf79IUMojUfg9Xc9VzGCias35+emkIeEO7QBkT2wDihFkjjIunqch3niaHS9tyM7Bd2uxZlxtFLkj4LqNcwRx6m6czrrICZpgMzTiq8ZABxiBGyhmjcKyj2PX4/5W6kYJGFLbhC9c5iUixRo2Rl590fQCX0+8y1/lOpjBfoDpLSbFONqMWxPxNOU6DS8XJEgf07zEa98ZH/NJyeeVCoUb1QVTSL13VVJARS54X5ygB0mLoUypp+JuP83fCh7b+g+P+cIxOnliGhU/1gXzMQXHX1Gb/plEJqLmzlFfBjyZnkGmkv0rdxPnt3ckWrIliALY8gqeJyf7/9IWYR7u+2ZCEfLpvKDGuJhE9BNmGQuosTiU0BXHcUXG10Gh3AVJK/Bovk="
          git config --global commit.gpgsign true
          git config --global gpg.format ssh
          git config --global gpg.ssh.allowedSignersFile `pwd`/allowed_signers

          # use our gitignore file, we are not duplicating our gitconfig for Codespaces
          git config --global core.excludesfile `pwd`/gitignore

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
     ;;

     Linux) # Github Codespace / VsCode devcontainers
          # use a correct sh system
          sudo apt update
          sudo apt install -y zsh
          sudo chsh -s $(which zsh) $(whoami)
     ;;
esac