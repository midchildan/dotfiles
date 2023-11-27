{ lib, config, ... }:

let
  inherit (config.dotfiles) flakeOptions;
in
{
  system.stateVersion = lib.mkDefault flakeOptions.darwin.stateVersion;
}
