#!/usr/bin/env bash

URL="https://github.com/midchildan/dotfiles/archive/gh-pages.tar.gz"

main() {
  export DOTDIR="$(mktemp -d)"

  echo "Downloading dotfiles..."
  download "$URL" | tar xzf - -C "$DOTDIR" --strip-components=1 \
    || abort "unable to download dotfiles"

  echo "Setting environment variables..."
  export INPUTRC="$DOTDIR/.inputrc"
  export SCREENRC="$DOTDIR/.screenrc"
  export MYVIMRC="$DOTDIR/.vimrc"
  export VIMINIT='source $MYVIMRC'
  export ZDOTDIR="$DOTDIR"

  echo "Launching $SHELL..."
  case "$SHELL" in
    *bash)
      exec "$SHELL" --rcfile "$DOTDIR/.bashrc" ;;
    *)
      exec $SHELL ;;
  esac
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
