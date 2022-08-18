{ lib
, path
, git
, nvfetcher
, writers
}:

writers.writeBash "update.sh" ''
  set -euxo pipefail

  export PATH="${lib.makeBinPath [ git nvfetcher ]}''${PATH:+:$PATH}"
  export NIX_PATH='nixpkgs=${path}'

  if ! [[ -f flake.nix && -d packages ]] ||
    [[ "$(git rev-parse --is-inside-work-tree)" != "true" ]]; then
    printf '[ERROR] This script appears to be run from the wrong directory. ' >&2
    printf 'Re-run this script from the root of the dotfiles repository.\n' >&2
  fi

  nix flake update
  git submodule update --init --remote

  pushd packages
  nvfetcher
  popd
''
