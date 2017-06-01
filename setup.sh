#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && DOTFILE_DIR=~/Library/dotfiles

main() {
  local install_plugins=""
  for n in "$@"; do
    case "$n" in
      --install-plugins)
        install_plugins=yes
        ;;
      *)
        ;;
    esac
  done

  cd "$DOTFILE_DIR"

  echo "$(tput bold)== Updating submodules ==$(tput sgr0)"
  git submodule update --init --remote

  echo "$(tput bold)== Installing configuration ==$(tput sgr0)"
  setup::shell
  setup::vim
  setup::gpg
  setup::misc

  if [[ -n "$install_plugins" ]]; then
    echo "$(tput bold)== Installing plugins ==$(tput sgr0)"
    setup::install_plugins
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

  local mvim_dir=/usr/local/bin
  local old_pwd="$(pwd)"
  cd "$mvim_dir"
  if [[ -x "$mvim_dir/mvim" ]]; then
    ln -s mvim vi
    ln -s mvim view
    ln -s mvim vim
    ln -s mvim vimdiff
    ln -s mvim vimex
  else
    [[ -e vi ]] || rm vi
    [[ -e view ]] || rm view
    [[ -e vim ]] || rm vim
    [[ -e vimdiff ]] || rm vimdiff
    [[ -e vimex ]] || rm vimex
  fi
  cd "$old_pwd"
}

setup::gpg() {
  if [[ ! -d ~/.gnupg ]]; then
    mkdir ~/.gnupg
    chmod 700 ~/.gnupg
  fi
  chmod 700 "$DOTFILE_DIR/home/.gnupg"
  chmod 600 "$DOTFILE_DIR/home/.gnupg/gpg-agent.conf"
  chmod 600 "$DOTFILE_DIR/home/.gnupg/gpg.conf"
  install_symlink ".gnupg/gpg-agent.conf"
  install_symlink ".gnupg/gpg.conf"
  install_symlink "Library/LaunchAgents/org.gnupg.gpg-agent.plist"
}

setup::misc() {
  install_symlink ".clang-format"
  install_symlink ".config/git/config"
  install_symlink ".config/git/ignore"
  install_symlink ".config/latexmk/latexmkrc"
  install_symlink ".config/ranger/rc.conf"
  install_symlink ".config/ranger/scope.sh"
  install_symlink ".config/zathura/zathurarc"
  install_symlink ".ipython/profile_default/ipython_config.py"
  install_symlink ".local/bin/rmpkg"
  install_symlink ".local/bin/imgcat"
  install_symlink ".local/share/zsh/site-functions"
  install_symlink ".mikutter/plugin"
  install_symlink ".screenrc"
  install_symlink ".tern-config"
  install_symlink ".tmux.conf"

  # gtk
  install_symlink ".gtkrc-2.0"
  install_symlink ".themes/zuki-themes"

  # spacemacs
  [[ ! -d ~/.emacs.d ]] && git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
  install_symlink ".spacemacs"

  # vscode
  install_symlink "Library/Application Support/Code/User/settings.json"
  chmod 700 ~/Library/Application\ Support/Code
}

setup::install_plugins() {
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
