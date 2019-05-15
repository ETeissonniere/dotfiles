ln -sf `pwd`/vimrc ~/.vimrc
ln -sf `pwd`/gitconfig ~/.gitconfig
ln -sf `pwd`/gitignore ~/.gitignore
ln -sf `pwd`/bash_profile ~/.bash_profile

mkdir -p ~/.gnupg
ln -sf `pwd`/gpg.conf ~/.gnupg/gpg.conf
ln -sf `pwd`/gpg-agent.conf ~/.gnupg/gpg-agent.conf
