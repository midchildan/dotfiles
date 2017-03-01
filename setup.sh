#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && DOTFILE_DIR=~/Library/dotfiles

main() {
  local install_deps=""
  for n in "$@"; do
    case "$n" in
      --install-deps)
        install_deps=yes
        ;;
      *)
        ;;
    esac
  done

  cd "$DOTFILE_DIR"

  echo "$(tput bold)== Cloning submodules ==$(tput sgr0)"
  git submodule update --init --recursive

  echo "$(tput bold)== Installing configuration ==$(tput sgr0)"
  setup::shell
  setup::vim
  setup::gpg
  setup::misc

  if [[ -n "$install_deps" ]]; then
    echo "$(tput bold)== Installing dependencies ==$(tput sgr0)"
    shell::install_deps
  fi
}

######################
#  helper functions  #
######################

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

###########
#  setup  #
###########

setup::shell() {
  install_symlink ".bash_profile"
  install_symlink ".bashrc"
  install_symlink ".zshenv"
  install_symlink ".zshrc"
  install_symlink ".inputrc"
}

setup::vim() {
  install_symlink ".vimrc"
  install_symlink ".gvimrc"
  install_symlink ".vim"
  install_symlink ".config/nvim"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

setup::gpg() {
  if [[ ! -d ~/.gnupg ]]; then
    mkdir ~/.gnupg
    chmod 700 ~/.gnupg
  fi
  chmod 700 $DOTFILE_DIR/home/.gnupg
  chmod 600 $DOTFILE_DIR/home/.gnupg/gpg-agent.conf
  chmod 600 $DOTFILE_DIR/home/.gnupg/gpg.conf
  install_symlink ".gnupg/gpg-agent.conf"
  install_symlink ".gnupg/gpg.conf"
  install_symlink "Library/LaunchAgents/org.gnupg.gpg-agent.plist"
}

setup::misc() {
  install_symlink ".clang-format"
  install_symlink ".config/git/config"
  install_symlink ".config/git/ignore"
  install_symlink ".config/zathura/zathurarc"
  install_symlink ".ipython/profile_default/ipython_config.py"
  install_symlink ".latexmkrc"
  install_symlink ".local/bin/rmpkg"
  install_symlink ".local/share/zsh/site-functions"
  install_symlink ".mikutter/plugin"
  install_symlink ".tern-config"
  install_symlink ".tmux.conf"

  install_symlink ".gtkrc-2.0"
  install_symlink ".themes/zuki-themes"
}

setup::install_deps() {
  brew update
  brew install \
    cmake \
    rust \
    node \
    zsh-completions \
    zsh-syntax-highlighting

  vim +PlugInstall +qall
}

main "$@"
