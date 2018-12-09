read -p "[DOTFILES] Please make sure you are logged in the Mac App Store"

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew analytics off

brew cask install google-chrome
brew cask install docker
brew cask install sublime-text
brew cask install drawio
brew cask install ledger-live

brew install git
brew install hub
brew install go
brew install node
brew install yarn
brew install awscli
brew install coffeescript
brew install kubectl
brew install bash-completion
brew install dockutil

brew install mas
mas lucky Pages
mas lucky Keynote
mas lucky Numbers
mas lucky Slack

# Will pop up and ask to install docker
open -a "Docker"
