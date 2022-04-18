ln -s `pwd`/gitconfig ~/.gitconfig || echo "skipping overwrite"
ln -s `pwd`/gitignore ~/.gitignore || echo "skipping overwrite"
ln -s `pwd`/zshrc ~/.zshrc || echo "skipping overwrite"
mkdir -p ~/.gnupg
ln -s `pwd`/gpg.conf ~/.gnupg/gpg.conf || echo "skipping overwrite"
ln -s `pwd`/gpg-agent.conf ~/.gnupg/gpg-agent.conf || echo "skipping overwrite"
mkdir -p ~/.ssh
ln -s `pwd`/ssh ~/.ssh/config || echo "skipping overwrite"
