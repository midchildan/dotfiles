{
  config,
  lib,
  pkgs,
  ...
}:

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
              insert-directory-program "${pkgs.coreutils}/bin/ls"
              treemacs-python-executable "${pkgs.python3}/bin/python")
      '';
      extraPackages =
        epkgs: with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          emacsql
          pdf-tools
          vterm
        ];
    };

    home.activation = lib.mkIf config.programs.emacs.enable {
      syncDoomEmacs = lib.hm.dag.entryAfter [ "installPackages" ] ''
        queryEmacsVersion() {
          local emacs="$1"
          "$emacs" --batch --eval '(princ (format "%d\n" emacs-major-version))'
        }

        syncDoomEmacs() {
          local oldEmacs newEmacs
          oldEmacs="$(readlink -m "''${oldGenPath:-/nonexistent}/home-path/bin/emacs")"
          newEmacs="$(readlink -m "$newGenPath/home-path/bin/emacs")"
          if [[ "$newEmacs" == "$oldEmacs" ]]; then
            return
          fi
          if [[ -x "${homeDir}/.config/emacs/bin/doom" ]]; then
            noteEcho 'This may take a while...'

            local maxfiles
            maxfiles="$(ulimit -n)"
            ulimit -n hard

            PATH="$newGenPath/home-path/bin:${pkgs.git}/bin:$PATH" \
              $DRY_RUN_CMD "${homeDir}/.config/emacs/bin/doom" \
                ''${VERBOSE:+-d} sync -e > /dev/null

            oldVersion="$(queryEmacsVersion "$oldEmacs")"
            newVersion="$(queryEmacsVersion "$newEmacs")"
            if (( oldVersion != newVersion )); then
              PATH="$newGenPath/home-path/bin:$PATH" \
                $DRY_RUN_CMD "${homeDir}/.config/emacs/bin/doom" \
                  ''${VERBOSE:+-d} build > /dev/null
            fi

            ulimit -n "$maxfiles"
          fi
        }

        syncDoomEmacs
      '';
    };
  };
}
