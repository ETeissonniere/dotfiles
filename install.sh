networksetup -setdnsservers Wi-Fi 1.1.1.1

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew analytics off

brew cask install google-chrome
brew cask install docker
brew cask install sublime-text

brew install git
brew install go
brew install node
brew install coffeescript
brew install kubectl
brew install bash-completion

./update.sh
