#!/usr/bin/env bash

DOTFILE_DIR="${DOTFILE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILE_DIR/scripts/setup"

main() {
  local mvim_bin=/Applications/MacVim.app/Contents/bin/mvim
  local dst_dir=/usr/local/bin

  [[ -x "$mvim_bin" ]] || return
  echo -n "Installing $dst_dir/mvim..."
  dot::_ln "$mvim_bin" "$dst_dir/mvim"
  dot::_print_badge

  cd "$dst_dir"
  for item in vi view vim vimdiff vimex; do
    echo -n "Setting $item to mvim..."
    dot::_ln mvim "$item"
    dot::_print_badge
  done
}

main
