networksetup -setdnsservers Wi-Fi 1.1.1.1

xcode-select --install

git clone https://github.com/ETeissonniere/dotfiles ~/.dotfiles
cd ~/.dotfiles

./update.sh
./mac_defaults.sh
./mac_apps.sh
