#!/usr/bin/env bash

URL="https://github.com/midchildan/dotfiles/archive/gh-pages.tar.gz"
IGNOREFILES=(
  README.md
  LICENSE
)

setup_environment() {
  export DOTROOT="$1"
  export INPUTRC="$DOTROOT/.inputrc"
  export SCREENRC="$DOTROOT/.screenrc"
  export ZDOTDIR="$DOTROOT"

  # shellcheck disable=SC2016
  export VIMINIT='source $MYVIMRC'
  export MYVIMRC="$DOTROOT/.vimrc"
}

main() {
  local shell="${SHELL:-sh}"
  local dotroot=

  while getopts "s:d:h" OPT; do
    case "$OPT" in
      s) shell="$OPTARG" ;;
      d) dotroot="$OPTARG" ;;
      h|*) usage; return 1 ;;
    esac
  done

  [[ -z "$dotroot" ]] && dotroot="$(mktemp -d)"

  echo "Downloading dotfiles..."
  if ! download "$URL" | extract_to "$dotroot"; then
    log::error "unable to download dotfiles"
    return 1
  fi

  echo "Setting environment variables..."
  setup_environment "$dotroot"

  echo "Launching $shell..."
  case "$shell" in
    *bash)
      exec "$shell" --rcfile "$dotroot/.bashrc" ;;
    *)
      # shellcheck disable=SC2086
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

log::error() {
  echo "[ERROR] $*" >&2
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
    log::error "curl or wget is required"
    return 1
  fi
}

extract_to() {
  tar xzf - -C "$1" --strip-components=1 "${IGNOREFILES[@]/#/--exclude=}"
}

main "$@"
