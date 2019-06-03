do_cd_sh () {
    echo "[DOTFILES] Installing $1"
    cd ~/.dotfiles/$1 && ./*.sh
}

xcode-select --install
read -p "[DOTFILES] Press enter when command lines tools are installed"

FOLDER=~/.dotfiles
URL=https://github.com/ETeissonniere/dotfiles
if [ ! -d "$FOLDER" ] ; then
    git clone "$URL" "$FOLDER"
fi

do_cd_sh configs
do_cd_sh tools
do_cd_sh prefs
