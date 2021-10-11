FOLDER=~/.dotfiles
URL=https://github.com/ETeissonniere/dotfiles

if [ ! -d "$FOLDER" ] ; then
    git clone "$URL" "$FOLDER"
else
    cd "$FOLDER"
    git pull $URL
fi

cd $FOLDER
./confs.sh
./prefs.sh
