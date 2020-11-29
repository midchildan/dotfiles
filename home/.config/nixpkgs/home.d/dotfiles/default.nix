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

  options.programs.dotfiles.enableAll =
    mkEnableOption "Enable all modules available under programs.dotfiles";

  config = mkIf config.programs.dotfiles.enableAll {
    programs.dotfiles = {
      essential.enable = mkDefault true;
      debugTools.enable = mkDefault true;
      desktop.enable = mkDefault true;
      development.enable = mkDefault true;
    };
  };
}
