FOLDER="$HOME/.dotfiles"
URL=https://github.com/ETeissonniere/dotfiles

if [ ! -d "$FOLDER" ]; then
    git clone "$URL" "$FOLDER"
else
    cd "$FOLDER" || exit 1
    git pull
fi

cd "$FOLDER" || exit 1
./prefs.sh
