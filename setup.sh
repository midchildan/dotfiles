#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && $DOTFILE_DIR=~/Library/dotfiles

# Shell
ln -s $DOTFILE_DIR/home/.bash_profile ~/.bash_profile
ln -s $DOTFILE_DIR/home/.bashrc ~/.bashrc
ln -s $DOTFILE_DIR/home/.zshenv ~/.zshenv
ln -s $DOTFILE_DIR/home/.zshrc ~/.zshrc
ln -s $DOTFILE_DIR/home/.inputrc ~/.inputrc

# Vim
mkdir -p ~/Library/Caches/vim/backup
mkdir -p ~/Library/Caches/vim/swap
mkdir -p ~/Library/Caches/vim/undo
mkdir -p ~/.vim
ln -s $DOTFILE_DIR/home/.vimrc ~/.vimrc
ln -s $DOTFILE_DIR/home/.gvimrc ~/.gvimrc
ln -s $DOTFILE_DIR/home/.vim/after ~/.vim/after
ln -s $DOTFILE_DIR/home/.vim/ycm_extra_conf.py ~/.vim/ycm_extra_conf.py
ln -s $DOTFILE_DIR/.vimrc ~/.vim/init.vim
ln -s ~/.vim ~/.config/nvim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# GnuPG
mkdir ~/.gnupg
chmod 600 .gnupg
ln -s $DOTFILE_DIR/home/.gnupg/gpg-agent.conf ~/.gnupg/gpg-agent.conf
ln -s $DOTFILE_DIR/home/.gnupg/gpg.conf ~/.gnupg/gpg.conf
ln -s $DOTFILE_DIR/Library/LaunchAgents/org.gnupg.gpg-agent.plist \
  ~/Library/LaunchAgents/org.gnupg.gpg-agent.plist

# GTK
git submodule init
git submodule update
mkdir ~/.themes
ln -s $DOTFILE_DIR/.themes/zuki-themes ~/.themes/zuki-themes
ln -s $DOTFILE_DIR/.gtkrc-2.0 ~/.gtkrc-2.0

# IPython
mkdir -p ~/.ipython/profile_default
ln -s $DOTFILE_DIR/home/.ipython/profile_default/ipython_config.py \
  ~/.ipython/profile_default/ipython_config.py

# mikutter
mkdir ~/.mikutter
ln -s $DOTFILE_DIR/home/.mikutter/plugin ~/.mikutter/plugin

# Others
ln -s $DOTFILE_DIR/.clang-format ~/.clang-format
ln -s $DOTFILE_DIR/.gitconfig ~/.gitconfig
ln -s $DOTFILE_DIR/.latexmkrc ~/.latexmkrc
ln -s $DOTFILE_DIR/.tern-config ~/.tern-config
ln -s $DOTFILE_DIR/.tmux.conf ~/.tmux.conf
