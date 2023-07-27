{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  options.dotfiles.profiles.desktop.enable =
    lib.mkEnableOption "essential packages for desktop environemnts";

  config = lib.mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      lib.optionals isLinux [
        anki
        gimp
        ink
        kitty
        libreoffice
        lollypop
        vlc
        xclip
      ];

    dotfiles.emacs.enable = lib.mkDefault true;
    dotfiles.profiles = {
      fonts.enable = lib.mkDefault true;
      macos.enable = lib.mkDefault isDarwin;
      web.enable = lib.mkDefault true;
    };
  };
}
