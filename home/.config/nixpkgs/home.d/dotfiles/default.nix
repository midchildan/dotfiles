{ config, lib, ... }:

with lib;

{
  imports = [
    ./modules/minimal.nix
    ./modules/essential.nix
    ./modules/debugtools.nix
    ./modules/desktop.nix
    ./modules/development.nix
    ./news.nix
  ];

  options.profiles.enableAll =
    mkEnableOption "Enable all profiles provided by the dotfiles";

  config = mkIf config.profiles.enableAll {
    profiles = {
      essential.enable = mkDefault true;
      debugTools.enable = mkDefault true;
      desktop.enable = mkDefault true;
      development.enable = mkDefault true;
    };
  };
}
