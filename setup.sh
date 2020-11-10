#!/bin/bash

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
  mv ~/.bashrc ~/.bashrc.old
  mv ~/.bash_logout ~/.bash_logout.old
  install::default ".bash_profile"
  install::default ".bashrc"
  install::default ".bash_logout"
  install::default ".zshenv"
  install::default ".zshrc"
  install::default ".emacs.d"
  install::default ".zlogout"
  install::default ".inputrc"
  install::default ".config/shell/snippets/common.snip"
  install::default ".config/shell/snippets/linux.snip"
  install::default ".config/shell/templates"
  install::default ".config/shell/templates.csv"
  install::default ".local/share/zsh/site-functions"
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
  install::default ".nixpkgs/config.nix"
  install::default ".screenrc"
  install::default ".tern-config"
  install::default ".tmux.conf"
  install::default ".wgetrc"
  install::default ".xprofile"
  install::default ".xmonad"

  # gdb
  install::default ".gdbinit"
  install::default ".local/bin/pwndbg"

  # LaTeX
  install::default ".config/latexmk/latexmkrc"
  install::default ".local/bin/platexmk"
  install::default ".local/bin/uplatexmk"
}

setup::prune() {
  prune ".gitconfig"
  prune ".latexmkrc"
  prune ".config/shell/common.snip"
}

setup::deps() {
  sudo apt-get update
  sudo apt-get install -y \
    build-essential \
    cmake \
    cmigemo \
    npm \
    nodejs \
    zsh-syntax-highlighting\
    emacs\
    ruby\
    htop
  sudo ln -s /usr/bin/nodejs /usr/local/bin/node
  curl https://sh.rustup.rs -sSf | sh
  curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb\
      && sudo dpkg -i ripgrep_11.0.2_amd64.deb
  wget https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb\
       && sudo dpkg -i bat_0.12.1_amd64.deb
  rm ripgrep_11.0.2_amd64.deb
  emacs --script install.el
  git clone  --depth 1 https://github.com/eth-p/bat-extras.git\
      && sudo ./bat-extras/build.sh --install
  sudo apt install fzf
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

# Indicate whether the last command succeeded
# Arguments:
#   None
# Returns:
#   None
print_badge() {
  if [[ "$?" == 0 ]]; then
    print_badge::ok
  else
    print_badge::failed
  fi
}

# Indicate success
# Arguments:
#   None
# Returns:
#   None
print_badge::ok() {
  echo "[$(tput setaf 2)OK$(tput sgr0)]"
}

# Indicate failure
# Arguments:
#   None
# Returns:
#   None
print_badge::failed() {
  echo "[$(tput setaf 1)FAILED$(tput sgr0)]"
}

# Prints the relative path from the current directory to the given path
# Arguments:
#   path
# Returns:
#   None
# Dependencies:
#   coreutils, python, ruby, or perl
relative_path() {
  [[ "$#" != 1 ]] && abort "Wrong number of arguments."
  if command -v realpath >/dev/null 2>&1; then
    realpath --no-symlinks --relative-to=. "$1"
  elif command -v perl >/dev/null 2>&1; then
    perl -e "use File::Spec; print File::Spec->abs2rel('$1')"
  elif command -v ruby >/dev/null 2>&1; then
    ruby -e \
      "require 'pathname'; print(Pathname.new('$1').relative_path_from(Pathname.new('$(pwd)')))"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import os; print(os.path.relpath('$1'), end='')"
  elif command -v python2 >/dev/null 2>&1; then
    python2 -c \
      "from __future__ import print_function; import os; print(os.path.relpath('$1'), end='')"
  else
    abort "Needs coreutils, python, ruby, or perl."
  fi
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
  print_badge
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
    print_badge::failed
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
  install::_ln "$(relative_path "$src")" "$fname"
  print_badge

  cd "$old_pwd"
}

# Creates an symlink from $src to $dst
# Arguments:
#   src : source path
#   dst : destination path
# Returns:
#   None
install::_ln() {
  [[ "$#" != 2 ]] && abort "Wrong number of arguments."
  local src="$1"
  local dst="$2"

  # remove dead symlink
  [[ ! -L "$dst" || -e "$dst" ]] || rm "$dst" >>"$LOGFILE" 2>&1
  # install symlink
  [[ "$dst" -ef "$src" ]] || ln -s "$src" "$dst" >>"$LOGFILE" 2>&1
}

main "$@"
