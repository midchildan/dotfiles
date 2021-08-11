#!/usr/bin/env bash

set -euo pipefail

export NIX_PATH="darwin-config=$HOME/.config/nixpkgs/darwin.nix:$HOME/.nix-defexpr/channels${NIX_PATH:+:}${NIX_PATH:-}"

main() {
  nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
  nix-channel --update

  writeInitialConfig
  darwin-rebuild switch

  log::info "Consider removing packages from the root profile, since it's not"
  log::info "managed with nix-darwin:"
  log::info
  log::info '    sudo -H nix-env -e "*"'
  log::info '    sudo -H nix-channel --remove nixpkgs'
}

log::info() {
  echo "[INFO] $*" >&2
}

darwin-rebuild() {
  "$(nix-build '<darwin>' -A system --no-out-link)"/sw/bin/darwin-rebuild "$@"
}

getCurrentStateVersion() {
nix-instantiate --eval - <<EOF
let
  exampleCfg = import <darwin/modules/examples/simple.nix> {
    config = null;
    pkgs.vim = null;
  };
in
exampleCfg.system.stateVersion
EOF
}

writeInitialConfig() {
  if [[ -e ~/.config/nixpkgs/darwin.d/config.nix ]]; then
    log::info "$HOME/.config/nixpkgs/darwin.d/config.nix already exists."
    return
  fi

  cat > ~/.config/nixpkgs/darwin.d/config.nix <<EOF
{ ... }:

{
  # List of available options:
  # https://daiderd.com/nix-darwin/manual/index.html

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = $(getCurrentStateVersion);
}
EOF

  log::info 'Local config created in ~/.config/nixpkgs/darwin.d/config.nix.'
}

main "$@"
