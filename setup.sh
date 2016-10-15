#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && $DOTFILE_DIR=~/.config/dotfiles

git submodule init
git submodule update

# Shell
ln -s $DOTFILE_DIR/home/.bash_profile ~/.bash_profile
ln -s $DOTFILE_DIR/home/.bashrc ~/.bashrc
ln -s $DOTFILE_DIR/home/.zshenv ~/.zshenv
ln -s $DOTFILE_DIR/home/.zshrc ~/.zshrc
ln -s $DOTFILE_DIR/home/.inputrc ~/.inputrc

# Vim
mkdir -p ~/.cache/vim/backup
mkdir -p ~/.cache/vim/swap
mkdir -p ~/.cache/vim/undo
ln -s $DOTFILE_DIR/home/.vimrc ~/.vimrc
ln -s $DOTFILE_DIR/home/.gvimrc ~/.gvimrc
ln -s $DOTFILE_DIR/home/.vim ~/.vim
ln -s $DOTFILE_DIR/.config/nvim ~/.config/nvim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# GnuPG
mkdir ~/.gnupg
chmod 700 .gnupg
chmod 700 $DOTFILE_DIR/home/.gnupg
chmod 600 $DOTFILE_DIR/home/.gnupg/gpg-agent.conf
chmod 600 $DOTFILE_DIR/home/.gnupg/gpg.conf
ln -s $DOTFILE_DIR/home/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
ln -s $DOTFILE_DIR/home/.gnupg/gpg.conf ~/.gnupg/gpg.conf

# IPython
mkdir -p ~/.ipython/profile_default
ln -s $DOTFILE_DIR/home/.ipython/profile_default/ipython_config.py \
  ~/.ipython/profile_default/ipython_config.py

# mikutter
mkdir ~/.mikutter
ln -s $DOTFILE_DIR/home/.mikutter/plugin ~/.mikutter/plugin

# Others
mkdir -p ~/.local/opt
ln -s $DOTFILE_DIR/home/.local/opt/peda ~/.local/opt/peda
ln -s $DOTFILE_DIR/home/.clang-format ~/.clang-format
ln -s $DOTFILE_DIR/home/.gdbinit ~/.gdbinit
ln -s $DOTFILE_DIR/home/.gitconfig ~/.gitconfig
ln -s $DOTFILE_DIR/home/.latexmkrc ~/.latexmkrc
ln -s $DOTFILE_DIR/home/.tern-config ~/.tern-config
ln -s $DOTFILE_DIR/home/.tmux.conf ~/.tmux.conf
ln -s $DOTFILE_DIR/home/.xprofile ~/.xprofile
ln -s $DOTFILE_DIR/home/.xmonad ~/.xmonad