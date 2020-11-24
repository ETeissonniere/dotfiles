FOLDER=~/.dotfiles
URL=https://github.com/ETeissonniere/dotfiles

xcode-select --install
read -p "[DOTFILES] Press enter when command lines tools are installed"

if [ ! -d "$FOLDER" ] ; then
    git clone "$URL" "$FOLDER"
else
    cd "$FOLDER"
    git pull $URL
fi

cd $FOLDER
./confs.sh
./prefs.sh
