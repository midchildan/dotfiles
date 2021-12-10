{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  options.dotfiles.profiles.fonts.enable = mkOption {
    type = types.bool;
    default = config.dotfiles.profiles.desktop.enable;
    description = ''
      Whether to install recommended fonts. Disable this if you prefer to
      install fonts through the system.
    '';
  };

  config = mkIf config.dotfiles.profiles.fonts.enable {
    fonts.fontconfig.enable = mkDefault isLinux;

    home.packages = with pkgs; [
      fira-code
      powerline-symbols
      xkcd-font
      emacs-all-the-icons-fonts
    ];
  };
}
