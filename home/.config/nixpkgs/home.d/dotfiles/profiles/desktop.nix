{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDir = config.home.homeDirectory;
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

    dotfiles.profiles.fonts.enable = mkDefault true;

    programs.emacs = {
      enable = mkDefault true;
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          pdf-tools
          vterm
        ];
    };

    dotfiles.emacs.extraConfig = ''
      (setq emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3")
    '';

    home.activation = mkIf config.programs.emacs.enable {
      rebuildDoomEmacs = hm.dag.entryAfter [ "installPackages" ] ''
        rebuildDoomEmacs() {
          local oldEmacs newEmacs
          oldEmacs="$(readlink -m "$oldGenPath/home-path/bin/emacs")"
          newEmacs="$(readlink -m "$newGenPath/home-path/bin/emacs")"
          if [[ "$newEmacs" == "$oldEmacs" ]]; then
            return
          fi
          if [[ -x "${homeDir}/.emacs.d/bin/doom" ]]; then
            $DRY_RUN_CMD "${homeDir}/.emacs.d/bin/doom" ''${VERBOSE:+-d} build \
              > /dev/null
          fi
        }
        rebuildDoomEmacs
      '';
    };
  };
}
