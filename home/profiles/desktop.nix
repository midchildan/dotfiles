{ config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf optionals;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDir = config.home.homeDirectory;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "essential packages for desktop environemnts";

  config = mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      optionals isLinux [
        anki
        gimp
        ink
        kitty
        libreoffice
        lollypop
        vlc
        vscode
        xclip
      ];

    dotfiles.emacs.enable = mkDefault true;
    dotfiles.firefox.enable = mkDefault true;
    dotfiles.profiles.fonts.enable = mkDefault true;
    dotfiles.profiles.macos.enable = mkDefault isDarwin;
  };
}
