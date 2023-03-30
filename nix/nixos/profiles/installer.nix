{ lib, config, modulesPath, dotfiles, ... }:

let
  cfg = config.dotfiles.profiles.installer;
in
{
  options.dotfiles.profiles.installer.enable =
    lib.mkEnableOption "custom configuration for NixOS installation media";

  config = lib.mkIf cfg.enable {
    hardware.enableAllFirmware = true;
    nix.registry.dotfiles.flake = dotfiles;

    # Override the defaults in ../../config.toml
    system.stateVersion = config.system.nixos.release;
  };
}
