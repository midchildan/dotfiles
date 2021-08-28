{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDir = config.home.homeDirectory;
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
        lollypop
        virtmanager
        vlc
        vscode
        xclip
      ];

    dotfiles.profiles.fonts.enable = mkDefault true;
    dotfiles.profiles.macos.enable = mkDefault isDarwin;

    programs.emacs = {
      enable = mkDefault true;
      extraConfig = ''
        (setq dired-use-ls-dired t
              emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3"
              insert-directory-program "${pkgs.coreutils}/bin/ls"
              treemacs-python-executable "${pkgs.python3}/bin/python")
      '';
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          pdf-tools
          vterm
        ];
    };

    home.activation = mkIf config.programs.emacs.enable {
      rebuildDoomEmacs = hm.dag.entryAfter [ "installPackages" ] ''
        rebuildDoomEmacs() {
          local oldEmacs newEmacs
          oldEmacs="$(readlink -m "$oldGenPath/home-path/bin/emacs")"
          newEmacs="$(readlink -m "$newGenPath/home-path/bin/emacs")"
          if [[ "$newEmacs" == "$oldEmacs" ]]; then
            return
          fi
          if [[ -x "${homeDir}/.config/emacs/bin/doom" ]]; then
            $DRY_RUN_CMD "${homeDir}/.config/emacs/bin/doom" \
              ''${VERBOSE:+-d} build > /dev/null
          fi
        }
        rebuildDoomEmacs
      '';
    };
  };
}
