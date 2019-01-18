read -p "[DOTFILES] Please make sure you are logged in the Mac App Store"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew analytics off

brew cask install google-chrome
brew cask install docker
brew cask install drawio
brew cask install ledger-live
brew cask install android-studio
brew cask install iterm2

brew cask install vagrant
brew cask install virtualbox
brew cask install virtualbox-extension-pack

brew install git
brew install hub
brew install go
brew install node
brew install coffeescript
brew install dockutil
brew install zsh
brew install zplug

brew install mas
mas lucky Pages
mas lucky Keynote
mas lucky Numbers
mas lucky Slack

# Will pop up and ask to install docker
open -a "Docker"
