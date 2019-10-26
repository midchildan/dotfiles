#!/usr/bin/env bash

URL="https://github.com/midchildan/dotfiles/archive/gh-pages.tar.gz"

main() {
  local shell="$SHELL"
  local dotdir=

  while getopts "s:d:h" OPT; do
    case "$OPT" in
      s) shell="$OPTARG" ;;
      d) dotdir="$OPTARG" ;;
      h|*) usage; return 1 ;;
    esac
  done

  if [[ -n "$dotdir" ]]; then
    export DOTDIR="$dotdir"
  else
    export DOTDIR="$(mktemp -d)"
  fi

  echo "Downloading dotfiles..."
  download "$URL" | tar xzf - -C "$DOTDIR" --strip-components=1 \
    || abort "unable to download dotfiles"

  echo "Setting environment variables..."
  export INPUTRC="$DOTDIR/.inputrc"
  export SCREENRC="$DOTDIR/.screenrc"
  export MYVIMRC="$DOTDIR/.vimrc"
  export VIMINIT='source $MYVIMRC'
  export ZDOTDIR="$DOTDIR"

  echo "Launching $shell..."
  case "$shell" in
    *bash)
      exec "$shell" --rcfile "$DOTDIR/.bashrc" ;;
    *)
      exec $shell ;;
  esac
}

usage() {
cat <<EOF
usage: $(basename "$0") [-d <dir>] [-s <shell>]

options:
  -d <dir>	specify download directory
  -s <shell>	specify shell (default: \$SHELL)
EOF
}

abort() {
  echo "[ERROR] $*" >&2
  exit 1
}

has() {
  command -v "$1" > /dev/null
}

download() {
  if has curl; then
    curl -sSfL "$1"
  elif has wget; then
    wget -qO- "$1"
  else
    abort "curl or wget is required"
  fi
}

main "$@"
