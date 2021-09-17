{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.emacs;
  homeDir = config.home.homeDirectory;
in
{
  options.dotfiles.emacs.enable = lib.mkEnableOption "Doom Emacs";

  config = lib.mkIf cfg.enable {
    programs.emacs = {
      enable = lib.mkDefault true;
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

    home.activation = lib.mkIf config.programs.emacs.enable {
      rebuildDoomEmacs = lib.hm.dag.entryAfter [ "installPackages" ] ''
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
