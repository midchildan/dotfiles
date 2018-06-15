#!/bin/bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$(mktemp)"
[[ -z "$DOTFILE_DIR" ]] && DOTFILE_DIR=~/Library/dotfiles


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
  install::default ".zshenv"
  install::default ".zshrc"
  install::default ".inputrc"
  install::default ".config/shell/snippets/common.snip"
  install::default ".config/shell/snippets/macos.snip"
  install::default ".config/shell/templates"
  install::default ".config/shell/templates.csv"
  install::default ".local/share/zsh/site-functions"
}

setup::vim() {
  install::default ".vim"
  install::default ".config/nvim"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

  setup::vim::macvim
}

setup::vim::macvim() {
  local mvim_bin=/Applications/MacVim.app/Contents/bin/mvim
  local dst_dir=/usr/local/bin

  [[ -x "$mvim_bin" ]] || return
  echo -n "Installing $dst_dir/mvim..."
  install::_ln "$mvim_bin" "$dst_dir/mvim"
  print_badge

  local old_pwd="$(pwd)"
  cd "$dst_dir"
  for item in vi view vim vimdiff vimex; do
    echo -n "Setting $item to mvim..."
    install::_ln mvim "$item"
    print_badge
  done
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
  install::default ".gnupg/gpg-agent.conf"
  install::default ".gnupg/gpg.conf"
  install::default "Library/LaunchAgents/org.gnupg.gpg-agent.plist"
}

setup::misc() {
  install::default ".clang-format"
  install::default ".config/git/config"
  install::default ".config/git/ignore"
  install::default ".config/ranger/rc.conf"
  install::default ".config/ranger/scope.sh"
  install::default ".config/tig/config"
  install::default ".config/zathura/zathurarc"
  install::default ".ipython/profile_default/ipython_config.py"
  install::default ".local/bin/rmpkg"
  install::default ".local/bin/imgcat"
  install::default ".local/opt/fzftools"
  install::default ".local/opt/tmux-copycat"
  install::default ".mikutter/plugin"
  install::default ".nanorc"
  install::default ".screenrc"
  install::default ".tern-config"
  install::default ".tmux.conf"
  install::default ".wgetrc"

  # gtk
  install::default ".gtkrc-2.0"
  install::default ".themes/zuki-themes"

  # LaTeX
  install::default ".config/latexmk/latexmkrc"
  install::default ".local/bin/platexmk"
  install::default ".local/bin/uplatexmk"

  # spacemacs
  [[ ! -d ~/.emacs.d ]] && git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
  install::default ".spacemacs"

  # vscode
  install::default "Library/Application Support/Code/User/settings.json"
  chmod 700 ~/Library/Application\ Support/Code
}

setup::prune() {
  prune ".gitconfig"
  prune ".latexmkrc"
  prune ".vimrc"
  prune ".gvimrc"
  prune ".config/shell/common.snip"
}

setup::deps() {
  brew update
  brew install \
    cmake \
    cmigemo \
    fzf \
    node \
    ripgrep \
    zsh-completions \
    zsh-syntax-highlighting
  curl https://sh.rustup.rs -sSf | sh

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
