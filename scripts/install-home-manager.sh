#!/usr/bin/env bash

set -euo pipefail

export NIX_PATH="$HOME/.nix-defexpr/channels${NIX_PATH:+:}${NIX_PATH:-}"
IS_GENERIC_LINUX='false'

main() {
  if isLinux && ! isNixOS; then
    IS_GENERIC_LINUX='true'
  fi

  nix-channel --add https://nixos.org/channels/nixpkgs-unstable
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install

  writeInitialConfig
}

isLinux() {
  [[ "$OSTYPE" =~ ^linux ]]
}

isNixOS() {
  [[ -f /etc/os-release ]] && grep -q '^ID=nixos$' /etc/os-release
}

log::info() {
  echo "[INFO] $*" >&2
}

writeInitialConfig() {
  if [[ -e ~/.config/nixpkgs/home.d/config.nix ]]; then
    log::info "$HOME/.config/nixpkgs/home.d/config.nix already exists."
    return
  fi

  cat > ~/.config/nixpkgs/home.d/config.nix <<EOF
{ ... }:

{
  # List of available options:
  # https://nix-community.github.io/home-manager/options.html
  # https://github.com/midchildan/dotfiles/blob/master/docs/nix.md

  home.username = "$USER";
  home.homeDirectory = "$HOME";

  targets.genericLinux.enable = ${IS_GENERIC_LINUX:-false};

  # This option determines which Home Manager release the current configuration
  # is compatible with.
  home.stateVersion = "$(home-manager --version)";
}
EOF

  log::info 'Local config created in ~/.config/nixpkgs/home.d/config.nix.'
}

main "$@"
