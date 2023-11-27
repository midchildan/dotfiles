{ lib, config, ... }:

let
  inherit (config.dotfiles) flakeOptions;
in
{
  config.home.stateVersion = lib.mkDefault flakeOptions.home.stateVersion;
}
