{ config, lib, ... }:

{
  options.dotfiles.profiles.enableAll = lib.mkEnableOption "all profiles provided by the dotfiles";

  config = lib.mkIf config.dotfiles.profiles.enableAll {
    dotfiles.profiles = {
      essential.enable = lib.mkDefault true;
      extras.enable = lib.mkDefault true;
      debugTools.enable = lib.mkDefault true;
      desktop.enable = lib.mkDefault true;
      development.enable = lib.mkDefault true;
    };
  };
}
