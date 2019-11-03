#!/usr/bin/env bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

IGNOREFILES=(
  README.md
  UNLICENSE
)

main() {
  for n in "$@"; do
    case "$n" in
      -h|--help) usage ;;
    esac
  done

  (( $# < 1 )) && usage

  local remote_dst="$1"
  local treeish="${2:-gh-pages}"

  git -C "$DOTFILE_DIR" archive --format=tar.gz "$treeish" | send "$remote_dst"
}

send() {
  if [[ "$1" =~ : ]]; then
    local remote_dst="$1"
  else
    local remote_dst="$1:"
  fi
  local host="${remote_dst%%:*}"
  local path="${remote_dst#*:}"

  if [[ -n "$path" ]]; then
    ssh "$host" tar xzf - "${IGNOREFILES[@]/#/--exclude=}" -C "$path"
  else
    ssh "$host" tar xzf - "${IGNOREFILES[@]/#/--exclude=}"
  fi
}

usage() {
cat <<EOF
usage: $0 [options] [host[:path]] [treeish]

options:
  -h, --help		Show usage and exit

arguments:
  host		remote host
  path		remote path
  treeish	git commit/tree (default: gh-pages)

examples:
  Send the contents of master:home to example.com
  $ $0 example.com master:home

  Send the contents of gh-pages to example.com:/tmp/dotfiles
  $ $0 example.com:/tmp/dotfiles
EOF

exit 1
}

main "$@"
