#!/usr/bin/env bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$(mktemp)"
[[ -z "$DOTFILE_DIR" ]] && DOTFILE_DIR=~/.config/dotfiles


cleanup() {
  if [[ -s "$LOGFILE" ]]; then
    echo "$(tput bold)== Printing logs ==$(tput sgr0)"
    cat "$LOGFILE"
  fi
  rm "$LOGFILE"
}
trap cleanup EXIT

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

  echo "$(tput bold)== Updating submodules ==$(tput sgr0)"
  git submodule update --init --remote

  echo "$(tput bold)== Pruning dead symlinks ==$(tput sgr0)"
  setup::prune

  echo "$(tput bold)== Installing configuration ==$(tput sgr0)"
  setup::shell
  setup::vim
  setup::gpg
  setup::misc

  if [[ -n "$install_deps" ]]; then
    echo "$(tput bold)== Installing dependencies ==$(tput sgr0)"
    setup::deps
  fi
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
  install::default ".config/shell/snippets/common.snip"
  install::default ".config/shell/snippets/linux.snip"
  install::default ".config/shell/templates"
  install::default ".config/shell/templates.csv"
  install::default ".local/share/zsh/site-functions"
}

setup::vim() {
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
  install::default ".config/nano/nanorc"
  install::default ".config/ranger/rc.conf"
  install::default ".config/ranger/scope.sh"
  install::default ".config/tig/config"
  install::default ".config/zathura/zathurarc"
  install::default ".ipython/profile_default/ipython_config.py"
  install::default ".local/libexec/fzf/install"
  install::default ".local/opt/fzftools"
  install::default ".local/opt/tmux-copycat"
  install::default ".mikutter/plugin"
  install::default ".nixpkgs/config.nix"
  install::default ".screenrc"
  install::default ".tern-config"
  install::default ".tmux.conf"
  install::default ".wgetrc"
  install::default ".xprofile"
  install::default ".xmonad"

  # gdb
  install::default ".gdbinit"
  install::default ".local/bin/gef"
  install::default ".local/bin/peda"
  install::default ".local/bin/pwndbg"

  # LaTeX
  install::default ".config/latexmk/latexmkrc"
  install::default ".local/bin/platexmk"
  install::default ".local/bin/uplatexmk"

  # spacemacs
  [[ ! -d ~/.emacs.d ]] && git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
  install::default ".spacemacs"

  # vscode
  install::default ".config/Code/User/settings.json"
  chmod 700 ~/.config/Code
}

setup::prune() {
  prune ".gitconfig"
  prune ".latexmkrc"
  prune ".vimrc"
  prune ".gvimrc"
  prune ".config/shell/common.snip"
}

setup::deps() {
  vim +PlugInstall +qall
}

######################
#  helper functions  #
######################

# Print an error message and exit
# Arguments:
#   error_message
# Returns:
#   None
abort() {
  local message=""
  [[ -n "$1" ]] && message="$1"
  printf "%s():%s [ABORT] %s\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "$message" >&2
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

# Removes ~/$path_to_file if it is a dead symlink
# Arguments:
#   path_to_file : file to prune
# Returns:
#   None
prune() {
  [[ "$#" != 1 ]] && abort "Wrong number of arguments."
  [[ "$1" == /* ]] && abort "Cannot use absoulte path."

  echo -n "Pruning $1..."

  local filepath=~/"$1"
  [[ ! -L "$filepath" || -e "$filepath" ]] || rm "$filepath" >>"$LOGFILE" 2>&1
  if [[ "$?" == 0 ]]; then
    echo "[$(tput setaf 2)OK$(tput sgr0)]"
  else
    echo "[$(tput setaf 1)FAILED$(tput sgr0)]"
  fi
}

# Creates an symlink from $DOTFILE_DIR/home/$path_to_file to ~/$path_to_file
# Globals:
#   DOTFILE_DIR
# Arguments:
#   path_to_file : file to install
# Returns:
#   None
install::default() {
  [[ "$#" != 1 ]] && abort "Wrong number of arguments."
  [[ "$1" == /* ]] && abort "Cannot use absoulte path."

  echo -n "Installing $1..."
  if [[ ! -e "$DOTFILE_DIR/home/$1" ]]; then
    echo "$DOTFILE_DIR/home/$1 does not exist" >>"$LOGFILE"
    return
  fi

  local dir="$(dirname "$1")"
  local old_pwd="$(pwd)"
  if [[ -n "$dir" ]] && [[ "$dir" != "." ]]; then
    [[ ! -d ~/"$dir" ]] && mkdir -p ~/"$dir"
    cd ~/"$dir"
  else
    cd
  fi

  local fname="$(basename "$1")"
  local src="$DOTFILE_DIR/home/$1"
  # remove dead symlink
  [[ ! -L "$fname" || -e "$fname" ]] || rm "$fname" >>"$LOGFILE" 2>&1
  # install symlink
  [[ "$fname" -ef "$src" ]] ||
    ln -s "$(relative_path "$src")" . >>"$LOGFILE" 2>&1

  if [[ "$?" == 0 ]]; then
    echo "[$(tput setaf 2)OK$(tput sgr0)]"
  else
    echo "[$(tput setaf 1)FAILED$(tput sgr0)]"
  fi

  cd "$old_pwd"
}

main "$@"
