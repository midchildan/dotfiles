{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isLinux;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "Essential packages for NixOS desktops";

  config = mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      [ emacs ffmpeg-full youtube-dl ] ++ optionals isLinux [
        anki
        firefox-bin
        gimp
        kitty
        libreoffice
        manpages
        sourcetrail
        sqlite # needed for org-roam w/ doom emacs
        virtmanager
        vlc
        vscode
        xclip

        # consider removing this and installing this system-wide instead
        emacs-all-the-icons-fonts
      ];
  };
}
