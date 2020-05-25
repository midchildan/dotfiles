#!/usr/bin/env bash

# Script to change user information

# This is one of the very few scripts where portability matters. Normally I'd
# deal with portability issues by using different git branches to handle
# platform differences, freeing the script of the need to handle it by itself.
# This script however, is intended to be run on the master branch regardless of
# which platform it's actually being used on. For this reason, this script uses
# perl instead of sed which is incompatible between GNU and BSD variants.

DOTFILE_DIR="${DOTFILE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

main() {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" != "master" ]]; then
    echo "Warning: current branch not 'master'"
  fi

  read -p "Enter your name: " NAME
  read -p "Enter your email: " EMAIL
  read -p "Enter your GPG key id (leave empty if none): " GPGKEYID

  echo "Patching..."
  patch::git
  patch::gpg

  echo "Registering remote 'upstream'..."
  git remote add upstream https://github.com/midchildan/dotfiles.git

  echo "Complete! You can commit the changes by running:"
  echo "  export GIT_AUTHOR_NAME=\"$NAME\""
  echo "  export GIT_COMMITTER_NAME=\"$NAME\""
  echo "  export EMAIL=\"$EMAIL\""
  echo "  git commit -am 'replace profile information'"
}

patch::git() {
  git::config user.name "$NAME"
  git::config user.email "$EMAIL"
  if [[ -n "$GPGKEYID" ]]; then
    git::config commit.gpgsign true
    git::config user.signingkey "$GPGKEYID"
  else
    git::config --unset-all commit.gpgsign
    git::config --unset-all user.signingkey
  fi
}

patch::gpg() {
  local confpath="$DOTFILE_DIR/home/.gnupg/gpg.conf"

  if [[ -z "$GPGKEYID" ]]; then
    # if no keyid is specified, remove keyid setting
    perl -i -ne 'print unless /^default-key/' "$confpath"
    perl -i -pe 'if ($. == 1) { $_ = <> while m/^\n/ }' "$confpath"
  elif grep -q '^default-key' "$confpath"; then
    # if there's an existing keyid setting, replace it
    perl -i -pe "s/^default-key.*/default-key $GPGKEYID/" "$confpath"
  else
    # add keyid setting
    perl -i -pe "print \"default-key $GPGKEYID\n\n\" if \$. == 1" "$confpath"
  fi
}

git::config() {
  git config --file "$DOTFILE_DIR/home/.config/git/config" "$@"
}

main
