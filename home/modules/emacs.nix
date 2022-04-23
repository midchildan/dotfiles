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
      package = lib.mkDefault pkgs.emacsNativeComp;
      extraConfig = ''
        (setq dired-use-ls-dired t
              insert-directory-program "${pkgs.coreutils}/bin/ls"
              treemacs-python-executable "${pkgs.python3}/bin/python")
      '';
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          emacsql-sqlite
          pdf-tools
          vterm
        ];

      # FIXME: workaround for https://github.com/NixOS/nixpkgs/pull/169316#issuecomment-1105643481
      overrides = prev: final: lib.optionalAttrs pkgs.stdenv.isDarwin {
        emacsWithPackages = pkgsFn:
          let emacs = prev.withPackages pkgsFn;
          in
          emacs.overrideAttrs (old: {
            buildCommand = old.buildCommand + ''
              if [[ -f $out/Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
                substituteInPlace $out/Applications/Emacs.app/Contents/MacOS/Emacs \
                  --subst-var-by wrapperSiteLispNative "$deps/share/emacs/native-lisp:" \
                  --subst-var autoloadExpression
              fi
            '';
          });
      };
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
            local maxfiles
            maxfiles="$(ulimit -n)"
            ulimit -n hard

            PATH="$newGenPath/home-path/bin:$PATH" \
              $DRY_RUN_CMD "${homeDir}/.config/emacs/bin/doom" \
                ''${VERBOSE:+-d} build > /dev/null

            ulimit -n "$maxfiles"
          fi
        }

        rebuildDoomEmacs
      '';
    };
  };
}
