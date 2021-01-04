{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "Essential packages for desktop environemnts";

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

        # consider removing this and installing this system-wide instead
        emacs-all-the-icons-fonts
      ] ++ optional isNixOS manpages;

    programs.emacs = {
      enable = mkDefault true;
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          emacsql-sqlite3
          pdf-tools
          vterm
        ];
    };
  };
}
