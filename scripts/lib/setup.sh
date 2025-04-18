#!/usr/bin/env bash

# {{{ Preamble

DOTFILE_DIR="${DOTFILE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
DOTFILE_FILES_DIR="${DOTFILE_FILES_DIR:-files}"

_DOT_LOGFILE="$(mktemp)"
_DOT_ENABLE_GC=1
_DOT_GCROOT="$DOTFILE_DIR/.gcroot"
_DOT_IS_INIT=
_DOT_IS_VERBOSE=
_DOT_LNFLAGS=""
_DOT_SECTION=
_DOT_BOLD="$(tput bold)"
_DOT_RED="$(tput setaf 1)"
_DOT_GREEN="$(tput setaf 2)"
_DOT_CLEAR="$(tput sgr0)"


dot::_exit() {
  if [[ -s "$_DOT_LOGFILE" ]]; then
    echo "$_DOT_BOLD== Print logs ==$_DOT_CLEAR"
    cat "$_DOT_LOGFILE"
  fi
  rm "$_DOT_LOGFILE"
}
trap dot::_exit EXIT

# }}}
# {{{ DSL Syntax

# shellcheck disable=SC2120
run:() {
  _DOT_SECTION="shell"
  echo "$_DOT_BOLD== Run ${*:-shell commands} ==$_DOT_CLEAR"
  cd "$DOTFILE_DIR" || dot::_abort "can't enter dir $DOTFILE_DIR"
}

# shellcheck disable=SC2120
install:() {
  _DOT_SECTION="install"
  echo "$_DOT_BOLD== Install ${*:-Files} ==$_DOT_CLEAR"
  cd "$DOTFILE_DIR" || dot::_abort "can't enter dir $DOTFILE_DIR"
}

# shellcheck disable=SC2120
githooks:() {
  _DOT_SECTION="githooks"
  echo "$_DOT_BOLD== ${*:-Register Git hooks} ==$_DOT_CLEAR"
  cd "$DOTFILE_DIR" || dot::_abort "can't enter dir $DOTFILE_DIR"
}

-() {
  [[ -z "$_DOT_SECTION" ]] && return

  if [[ "$1" =~ .*: ]]; then
    dot::"${1%:}" "${@:2}"
    return
  fi

  case "$_DOT_SECTION" in
    shell) dot::shell::task "$@" ;;
    install) dot::install::task "$@" ;;
    githooks) dot::githooks::task "$@" ;;
  esac
}

# }}}
# {{{ Tasks

# Creates an symlink from $DOTFILE_DIR/$DOTFILE_FILES_DIR/$path_to_file to
# ~/$path_to_file
# Globals:
#   DOTFILE_DIR
# Arguments:
#   path_to_file : file to install
# Returns:
#   None
dot::install::task() {
  [[ "$#" != 1 ]] && dot::_abort "Wrong number of arguments."
  [[ "$1" == /* ]] && dot::_abort "Cannot use absoulte path."

  echo -n "Installing $1..."
  if [[ ! -e "$DOTFILE_DIR/$DOTFILE_FILES_DIR/$1" ]]; then
    echo "$DOTFILE_DIR/$DOTFILE_FILES_DIR/$1 does not exist" >&2
    dot::_print_badge::failed
    return
  fi

  local dir
  dir="$(dirname "$1")"
  if [[ -n "$dir" ]] && [[ "$dir" != "." ]]; then
    [[ ! -d ~/"$dir" ]] && mkdir -p ~/"$dir"
    pushd ~/"$dir" || dot::_abort "can't enter dir ~/$dir"
  else
    pushd ~ || dot::_abort "can't enter dir ~"
  fi

  local fname src
  fname="$(basename "$1")"
  src="$DOTFILE_DIR/$DOTFILE_FILES_DIR/$1"
  dot::_ln "$(dot::_relative_path "$src")" "$fname"
  dot::_print_badge

  popd || dot::_abort "Failed to change directory"
}

# Run a shell command
# Globals:
#   DOTFILE_DIR
# Arguments:
#   path_to_file : file to install
# Returns:
#   None
dot::shell::task() {
  dot::shell "$@"
}

# Symlinks $DOTFILE_DIR/scripts/githooks/$hook into $GIT_DIR/hook
# Globals:
#   DOTFILE_DIR
# Arguments:
#   hook : hook to install
# Returns:
#   None
dot::githooks::task() {
  [[ "$#" != 1 ]] && dot::_abort "Wrong number of arguments."
  [[ "$1" == /* ]] && dot::_abort "Cannot use absoulte path."

  echo -n "Registering $1 hook..."
  local hook="$1"
  local src="$DOTFILE_DIR/scripts/githooks/$hook"

  if [[ ! -e "$src" ]]; then
    echo "$src does not exist" >&2
    dot::_print_badge::failed
    return
  fi
  if [[ ! -d .git/hooks ]]; then
    echo "$DOTFILE_DIR/.git/hooks is not a directory" >&2
    dot::_print_badge::failed
    return
  fi

  pushd .git/hooks || dot::_abort "can't enter dir .git/hooks"
  dot::_ln "$(dot::_relative_path "$src")" "$hook"
  popd || dot::_abort "Failed to change directory"

  dot::_print_badge
}

# Skip section
# Globals:
#   _DOT_SECTION
# Arguments:
#   enable : Whether to skip the current section (true/false)
# Returns:
#   None
dot::skip() {
  case "$1" in
    true|yes|1)
      [[ -n "$_DOT_SECTION" ]] && echo "Skipping section..."
      _DOT_SECTION=
      ;;
    false|no|0)
      ;;
    *)
      dot::_abort "Invalid argument: $1"
      ;;
  esac
}

# Skip section unless --init is specified
# Globals:
#   _DOT_SECTION
#   _DOT_IS_INIT
# Arguments:
#   enable : Whether to skip the current section (true/false)
# Returns:
#   None
dot::init() {
  case "$1" in
    true|yes|1) [[ -z "$_DOT_IS_INIT" ]] && dot::skip true ;;
    false|no|0) return ;;
    *) dot::_abort "Invalid argument: $1" ;;
  esac
}

# Change current directory during the scope of the current section
# Arguments:
#   path : Path of the target directory
# Returns:
#   None
dot::cd() {
  (( $# != 1 )) && dot::_abort "Wrong number of arguments."
  cd "$1" || dot::_abort "can't enter dir $1"
}

# Changes file permissions for $DOTFILE_DIR/$DOTFILE_FILES_DIR/$path_to_file
# Globals:
#   DOTFILE_DIR
# Arguments:
#   enable : Whether to skip the current section (true/false)
# Returns:
#   None
dot::chmod() {
  (( $# != 2 )) && dot::_abort "Wrong number of arguments."
  chmod "$1" "$DOTFILE_DIR/$DOTFILE_FILES_DIR/$2"
}

# Clone a repository from GitHub
# Arguments:
#   repository: the target repository
#   dst: target directory
# Returns:
#   None
dot::github() {
  [[ -d "$2" ]] && return
  git clone --quiet "https://github.com/$1.git" "$2"
  echo "Cloning $1...$(dot::_print_badge)"
}

# Run a shell script
# Arguments:
#   path: target path/url
# Returns:
#   None
dot::script() {
  (( $# == 0 )) && dot::_abort "Wrong number of arguments."

  if [[ "$1" =~ ^https?:// ]]; then
    curl "$1" -sSf | bash
    ! (( PIPEFAIL[0] | PIPEFAIL[1] ))
  else
    bash "$DOTFILE_DIR/scripts/$1" "${@:2}"
  fi

  echo "Running $1...$(dot::_print_badge)"
}

# Run a shell command
# Arguments:
#   cmd: Command to run
# Returns:
#   None
dot::shell() {
  echo -n "Running $*..."
  "$@" >&2
  dot::_print_badge
}

# }}}
# {{{ Helpers

# Print an error message and exit
# Arguments:
#   error_message
# Returns:
#   None
dot::_abort() {
  local message=""
  [[ -n "$1" ]] && message="$1"
  printf "%s():%s [ABORT] %s\n" "${FUNCNAME[1]}" "${BASH_LINENO[0]}" "$message"
  exit 1
}

# Creates an symlink from $src to $dst
# Globals:
#   _DOT_ENABLE_GC
# Arguments:
#   src : source path
#   dst : destination path
# Returns:
#   None
dot::_ln() {
  [[ "$#" != 2 ]] && dot::_abort "Wrong number of arguments."
  local src="$1"
  local dst="$2"

  # install symlink
  if [[ ! "$dst" -ef "$src" ]]; then
    ln -sn"$_DOT_LNFLAGS" "$src" "$dst" \
      || return 1
  fi

  # Mark dst as GC root
  local abs_dst dst_hash
  [[ -z "$_DOT_ENABLE_GC" ]] && return
  abs_dst="$(dot::_absolute_path "$dst")"
  dst_hash="$(echo "$abs_dst" | sha256sum | cut -d' ' -f1)"
  ln -snf "$abs_dst" "$_DOT_GCROOT/$dst_hash" || :
}

# Indicate whether the last command succeeded
# Arguments:
#   None
# Returns:
#   None
dot::_print_badge() {
  # shellcheck disable=SC2181
  if [[ "$?" == 0 ]]; then
    dot::_print_badge::ok
  else
    dot::_print_badge::failed
  fi
}

# Indicate success
# Arguments:
#   None
# Returns:
#   None
dot::_print_badge::ok() {
  echo "[${_DOT_GREEN}OK${_DOT_CLEAR}]"
}

# Indicate failure
# Arguments:
#   None
# Returns:
#   None
dot::_print_badge::failed() {
  echo "[${_DOT_RED}FAILED${_DOT_CLEAR}]"
}

# Prints the absolute path of a given path
# Arguments:
#   path
# Returns:
#   None
# Dependencies:
#   coreutils, python, ruby, or perl
dot::_absolute_path() {
  [[ "$#" != 1 ]] && dot::_abort "Wrong number of arguments."
  if command -v realpath >/dev/null 2>&1; then
    realpath -s "$1"
  elif command -v perl >/dev/null 2>&1; then
    perl -e "use File::Spec; print File::Spec->rel2abs(\$ARGV[0])" "$1"
  elif command -v ruby >/dev/null 2>&1; then
    ruby -e \
      "require 'pathname'; print(Pathname.new(ARGV[0]).expand_path())" "$1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import os,sys; print(os.path.abspath(sys.argv[1]), end='')" "$1"
  elif command -v python2 >/dev/null 2>&1; then
    python2 -c \
      "from __future__ import print_function; import os,sys; print(os.path.abspath(sys.argv[1]), end='')" "$1"
  else
    dot::_abort "Needs coreutils, python, ruby, or perl."
  fi
}

# Prints the relative path from the current directory to the given path
# Arguments:
#   path
# Returns:
#   None
# Dependencies:
#   coreutils, python, ruby, or perl
dot::_relative_path() {
  [[ "$#" != 1 ]] && dot::_abort "Wrong number of arguments."
  if command -v realpath >/dev/null 2>&1; then
    realpath --no-symlinks --relative-to=. "$1"
  elif command -v perl >/dev/null 2>&1; then
    perl -e "use File::Spec; print File::Spec->abs2rel(\$ARGV[0])" "$1"
  elif command -v ruby >/dev/null 2>&1; then
    ruby -e \
      "require 'pathname'; print(Pathname.new(ARGV[0]).relative_path_from(Pathname.getwd))" "$1"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "import os,sys; print(os.path.relpath(sys.argv[1]), end='')" "$1"
  elif command -v python2 >/dev/null 2>&1; then
    python2 -c \
      "from __future__ import print_function; import os; print(os.path.relpath(sys.argv[1]), end='')" "$1"
  else
    dot::_abort "Needs coreutils, python, ruby, or perl."
  fi
}

# Wrapper for pushd
# Returns:
#   None
#
# shellcheck disable=SC2164
pushd() {
  builtin pushd "$@" > /dev/null
}

# Wrapper for popd
# Returns:
#   None
#
# shellcheck disable=SC2120,SC2164
popd() {
  builtin popd "$@" > /dev/null
}

# Wrapper for sha256sum
# Returns:
#   None
#
# shellcheck disable=SC2120
sha256sum() {
  if command -v sha256sum > /dev/null 2>&1; then
    command sha256sum "$@"
  elif command -v shasum > /dev/null 2>&1; then
    command shasum -a 256 "$@"
  else
    echo "[ERROR] sha256sum or shasum needs to be installed" >&2
  fi
}

# Wrapper for tput
# Returns:
#   None
tput() {
  case "$TERM" in
    ""|dumb) return ;;
    *) command tput "$@" ;;
  esac
}

# }}}
# {{{ Subcommands

dot::_command::uninstall() {
  local root link
  for root in "$_DOT_GCROOT"/*; do
    link="$(readlink "$root")"
    if [[ -L "$link" ]]; then
      echo -n "Removing $link..."
      rm "$link" "$root"
      dot::_print_badge
    fi
  done

  exit
}

dot::_command::help() {
cat <<EOF
usage: $0 [options] [command]

options:
  -h, --help		Print help message and exit
      --init		Run tasks marked "init: true"
  -f, --force		Overwrite existing symlinks
      --disable-gc	Disable garbage collection
  -V, --verbose		Enable verbose output

commands:
  install [default]
  uninstall
EOF

exit
}

# }}}
# {{{ Setup

dot::setup::parse_args() {
  local n
  for n in "$@"; do
    case "$n" in
      -h|--help) dot::_command::help ;;
      --init) _DOT_IS_INIT=1 ;;
      -f|--force) _DOT_LNFLAGS+="f" ;;
      --disable-gc) _DOT_ENABLE_GC= ;;
      -V|--verbose) _DOT_IS_VERBOSE=1 ;;
      uninstall) dot::_command::uninstall ;;
      *) ;;
    esac
  done
}

dot::setup::gc() {
  [[ -z "$_DOT_ENABLE_GC" ]] && return

  echo "$_DOT_BOLD== Remove dead symlinks ==$_DOT_CLEAR"
  local root link
  for root in "$_DOT_GCROOT"/*; do
    link="$(readlink "$root")"
    if [[ -L "$link" && ! -e "$link" ]]; then
      echo -n "Removing $link..."
      rm "$link" "$root"
      dot::_print_badge
    elif [[ ! -e "$root" ]]; then
      echo -n "Removing GC root for $link..."
      rm "$root"
      dot::_print_badge
    fi
  done
}

main() {
  dot::setup::parse_args "$@"

  # redirect stderr to log file
  if [[ -z "$_DOT_IS_VERBOSE" ]]; then
    exec 2>>"$_DOT_LOGFILE"
  fi

  dot::setup::gc
}

main "$@"

# }}}
# vim:set foldmethod=marker:
