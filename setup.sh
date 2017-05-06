#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -z "$DOTFILE_DIR" ]] && DOTFILE_DIR=~/.config/dotfiles

main() {
  cd "$DOTFILE_DIR"

  echo "$(tput bold)== Updating submodules ==$(tput sgr0)"
  git submodule update --init --remote

  echo "$(tput bold)== Installing configuration ==$(tput sgr0)"
  setup::shell
  setup::vim
  setup::gpg
  setup::misc
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
  realpath --no-symlinks --relative-to=. "$1"
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
  install_symlink ".bash_logout"
  install_symlink ".zshenv"
  install_symlink ".zshrc"
  install_symlink ".zlogout"
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
  chmod 700 "$DOTFILE_DIR/home/.gnupg"
  chmod 600 "$DOTFILE_DIR/home/.gnupg/gpg-agent.conf"
  chmod 600 "$DOTFILE_DIR/home/.gnupg/gpg.conf"
  install_symlink ".gnupg/gpg-agent.conf"
  install_symlink ".gnupg/gpg.conf"
}

setup::misc() {
  install_symlink ".clang-format"
  install_symlink ".config/git/config"
  install_symlink ".config/git/ignore"
  install_symlink ".config/latexmk/latexmkrc"
  install_symlink ".config/zathura/zathurarc"
  install_symlink ".gdbinit"
  install_symlink ".ipython/profile_default/ipython_config.py"
  install_symlink ".local/libexec/fzf/install"
  install_symlink ".local/opt/peda"
  install_symlink ".local/opt/pwndbg"
  install_symlink ".local/share/zsh/site-functions"
  install_symlink ".mikutter/plugin"
  install_symlink ".nixpkgs/config.nix"
  install_symlink ".screenrc"
  install_symlink ".tern-config"
  install_symlink ".tmux.conf"
  install_symlink ".xprofile"
  install_symlink ".xmonad"

  # spacemacs
  [[ ! -d ~/.emacs.d ]] && git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
  install_symlink ".spacemacs"

  # vscode
  install_symlink ".config/Code/User/settings.json"
  chmod 700 ~/.config/Code
}

main "$@"
