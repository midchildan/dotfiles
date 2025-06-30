{
  lib,
  config,
  pkgs,
  modulesPath,
  dotfiles,
  ...
}:

let
  cfg = config.dotfiles.profiles.installer;
in
{
  options.dotfiles.profiles.installer.enable =
    lib.mkEnableOption "custom configuration for NixOS installation media";

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = {
      bcachefs = true;
      zfs = lib.mkForce false;
    };

    hardware.enableAllFirmware = true;
    nix.registry.dotfiles.flake = dotfiles;

    environment.systemPackages = [ pkgs.git ];

    programs.nano.enable = false;

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      configure.luaRcContent = builtins.readFile ../../../files/.config/nvim/init.lua;
    };

    system.stateVersion = config.system.nixos.release;
  };
}
