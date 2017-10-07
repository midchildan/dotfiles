#!/usr/bin/env bash

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

###########
#  setup  #
###########

setup::shell() {
  install::default ".bash_profile"
  install::default ".bashrc"
  install::default ".bash_logout"
  install::default ".zshenv"
  install::default ".zshrc"
  install::default ".zlogout"
  install::default ".inputrc"
}

setup::vim() {
  install::default ".vimrc"
  install::default ".gvimrc"
  install::default ".vim"
  install::default ".config/nvim"
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
  install::default ".gnupg/gpg-agent.conf"
  install::default ".gnupg/gpg.conf"
}

setup::misc() {
  install::default ".clang-format"
  install::default ".config/git/config"
  install::default ".config/git/ignore"
  install::default ".config/latexmk/latexmkrc"
  install::default ".config/ranger/rc.conf"
  install::default ".config/ranger/scope.sh"
  install::default ".config/zathura/zathurarc"
  install::default ".gdbinit"
  install::default ".ipython/profile_default/ipython_config.py"
  install::default ".local/libexec/fzf/install"
  install::default ".local/opt/gef"
  install::default ".local/opt/peda"
  install::default ".local/opt/pwndbg"
  install::default ".local/share/zsh/site-functions"
  install::default ".mikutter/plugin"
  install::default ".nixpkgs/config.nix"
  install::default ".screenrc"
  install::default ".tern-config"
  install::default ".tmux.conf"
  install::default ".xprofile"
  install::default ".xmonad"

  # spacemacs
  [[ ! -d ~/.emacs.d ]] && git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
  install::default ".spacemacs"

  # vscode
  install::default ".config/Code/User/settings.json"
  chmod 700 ~/.config/Code
}

######################
#  helper functions  #
######################

# Print an error message and exit
# Arguments:
#   error_message [default: abort]
# Returns:
#   None
abort() {
  local message="abort"
  [[ -n "$1" ]] && message="$1"
  printf "[%s():%s] %s\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "$message" >&2
  exit 1
}

# Prints the relative path from the current directory to the given path
# Arguments:
#   path
# Returns:
#   None
# Dependencies:
#   coreutils, python, ruby, or perl
relative_path() {
  [[ "$#" != 1 ]] && abort "relative_path: Wrong number of arguments."
  realpath --no-symlinks --relative-to=. "$1"
}

# Creates an symlink from $DOTFILE_DIR/home/$path_to_file to ~/$path_to_file
# Globals:
#   DOTFILE_DIR
# Arguments:
#   path_to_file : file to install
# Returns:
#   None
install::default() {
  echo "Installing $1"

  [[ "$#" != 1 ]] && abort "Wrong number of arguments."
  [[ "$1" == /* ]] && abort "Cannot use absoulte path."
  [[ ! -e "$DOTFILE_DIR/home/$1" ]] &&
    abort "$DOTFILE_DIR/home/$1 does not exist."

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

# Creates an symlink from $DOTFILE_DIR/home/$path_to_file/$version to
# ~/$path_to_file
# Globals:
#   DOTFILE_DIR
# Arguments:
#   path_to_file : file to install
#   version [default: latest]
# Returns:
#   None
install::versioned() {
  echo "Installing $1"

  (( "$#" > 2 )) && abort "Wrong number of arguments."
  [[ "$1" == /* ]] && abort "Cannot use absoulte path."

  local dir="$(dirname "$1")"
  local fname="$(basename "$1")"
  local version="latest"
  [[ -n "$2" ]] && version="$2"
  [[ ! -e "$DOTFILE_DIR/home/$1/$version" ]] &&
    abort "$DOTFILE_DIR/home/$1/$version does not exist."

  local old_pwd="$(pwd)"
  if [[ -n "$dir" ]] && [[ "$dir" != "." ]]; then
    [[ ! -d ~/"$dir" ]] && mkdir -p ~/"$dir"
    cd ~/"$dir"
  else
    cd
  fi

  ln -s "$(relative_path "$DOTFILE_DIR/home/$1/$version")" "$fname"
  cd "$old_pwd"
}

main "$@"
