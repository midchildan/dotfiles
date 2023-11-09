{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  options.dotfiles.profiles.fonts.enable =
    lib.mkEnableOption "recommended fonts";

  config = lib.mkIf config.dotfiles.profiles.fonts.enable {
    fonts.fontconfig.enable = lib.mkDefault isLinux;

    home.packages = with pkgs; [
      fira-code
      xkcd-font
      (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    ];
  };
}
