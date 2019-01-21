do_cd_sh () {
    echo "Installing $1"
    cd ~/.dotfiles/$1 && ./*.sh
}

xcode-select --install
read -p "[DOTFILES] Press enter when command lines tools are installed"

git clone https://github.com/ETeissonniere/dotfiles ~/.dotfiles

do_cd_sh configs
do_cd_sh plugins
do_cd_sh tools
do_cd_sh prefs
