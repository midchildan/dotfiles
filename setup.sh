#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && $DOTFILE_DIR=~/.config/dotfiles

main() {
  cd "$DOTFILE_DIR"
  git submodule init
  git submodule update

  install_shell_config
  install_vim_config
  install_gpg_config
  install_misc
}

abort() {
  [[ -n "$1" ]] && echo "$1" >&2
  exit 1
}

relative_path() {
  [[ "$#" != 1 ]] && abort "relative_path: Wrong number of arguments."
  if [[ -x /usr/bin/realpath ]]; then
    /usr/bin/realpath --no-symlinks --relative-to=. "$1"
  elif [[ -x /usr/bin/perl ]]; then
    /usr/bin/perl -e "use File::Spec; print File::Spec->abs2rel('$1')"
  elif [[ -x /usr/bin/ruby ]]; then
    /usr/bin/ruby -e \
      "require 'pathname'; print(Pathname.new('$1').relative_path_from(Pathname.new('$(pwd)')))"
  elif [[ -x /usr/bin/python3 ]]; then
    /usr/bin/python3 -c "import os; print(os.path.relpath('$1'), end='')"
  elif [[ -x /usr/bin/python ]]; then
    /usr/bin/python -c \
      "from __future__ import print_function; import os; print(os.path.relpath('$1'), end='')"
  else
    abort "relative_path: Needs coreutils, python, ruby, or perl."
  fi
}

install_symlink() {
  [[ "$#" != 1 ]] && abort "install_symlink: Wrong number of arguments."
  [[ "$1" == /* ]] && abort "install_symlink: Cannot use absoulte path."
  [[ ! -e "$DOTFILE_DIR/home/$1" ]] &&
    abort "install_symlink: $DOTFILE_DIR/home/$1 does not exist."

  local dir="$(dirname "$1")"
  local old_pwd="$(pwd)"
  if [[ -n "$dir" ]] && [[ "$dir" != "." ]]; then
    [[ ! -d ~/"$dir" ]] && mkdir -p ~/"$dir"
    cd ~/"$dir"
  else
    cd
  fi

  ln -s "$(relative_path "$DOTFILE_DIR/home/$1")" .
  cd "$old_pwd"
}

install_shell_config() {
  install_symlink ".bash_profile"
  install_symlink ".bashrc"
  install_symlink ".bash_logout"
  install_symlink ".zshenv"
  install_symlink ".zshrc"
  install_symlink ".zlogout"
  install_symlink ".inputrc"
}

install_vim_config() {
  mkdir -p ~/.cache/vim/backup
  mkdir -p ~/.cache/vim/swap
  mkdir -p ~/.cache/vim/undo
  install_symlink ".vimrc"
  install_symlink ".gvimrc"
  install_symlink ".vim"
  install_symlink ".config/nvim"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

install_gpg_config() {
  if [[ ! -d ~/.gnupg ]]; then
    mkdir ~/.gnupg
    chmod 700 ~/.gnupg
  fi
  chmod 700 $DOTFILE_DIR/home/.gnupg
  chmod 600 $DOTFILE_DIR/home/.gnupg/gpg-agent.conf
  chmod 600 $DOTFILE_DIR/home/.gnupg/gpg.conf
  install_symlink ".gnupg/gpg-agent.conf"
  install_symlink ".gnupg/gpg.conf"
}

install_misc() {
  install_symlink ".clang-format"
  install_symlink ".config/git/config"
  install_symlink ".config/git/ignore"
  install_symlink ".config/zathura/zathurarc"
  install_symlink ".gdbinit"
  install_symlink ".ipython/profile_default/ipython_config.py"
  install_symlink ".latexmkrc"
  install_symlink ".local/opt/peda"
  install_symlink ".local/share/zsh/site-functions"
  install_symlink ".mikutter/plugin"
  install_symlink ".nixpkgs/config.nix"
  install_symlink ".tern-config"
  install_symlink ".tmux.conf"
  install_symlink ".xprofile"
  install_symlink ".xmonad"

  install_symlink ".local/bin/fzf"
  install_symlink ".local/bin/fzf-tmux"
}

main
