{ config, lib, ... }:

with lib;

{
  imports = [
    ./minimal.nix
    ./essential.nix
    ./debugtools.nix
    ./desktop.nix
    ./development.nix
  ];

  options.dotfiles.profiles.enableAll =
    mkEnableOption "Enable all profiles provided by the dotfiles";

  config = mkIf config.dotfiles.profiles.enableAll {
    dotfiles.profiles = {
      essential.enable = mkDefault true;
      debugTools.enable = mkDefault true;
      desktop.enable = mkDefault true;
      development.enable = mkDefault true;
    };
  };
}