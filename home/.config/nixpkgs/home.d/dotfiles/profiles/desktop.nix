{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "essential packages for desktop environemnts";

  config = mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      optionals isLinux [
        anki
        firefox-bin
        gimp
        kitty
        libreoffice
        virtmanager
        vlc
        vscode
        xclip
      ] ++ optional isNixOS manpages;

    programs.emacs = {
      enable = mkDefault true;
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          pdf-tools
          vterm
        ];
    };

    dotfiles.fonts.enable = mkDefault true;
    dotfiles.profiles.fonts.enable = mkDefault true;

    dotfiles.emacs.extraConfig = ''
      (setq emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3")
    '';
  };
}
