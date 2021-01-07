{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  fonts = pkgs.runCommandNoCC "home-manager-fonts" {
    paths = config.home.packages;
  } ''
    mkdir -p $out
    for path in $paths; do
      if [[ ! -d "$path/share/fonts" ]]; then
        continue
      fi
      find -L "$path/share/fonts" -type f -print0 | while IFS= read -rd "" f; do
        ln -s "$f" $out
      done
    done
  '';
in {
  options.dotfiles.fonts.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to enable font support for non-NixOS hosts.

      <warning>
        <para>
          On macOS, this may overwrite exsting files in ~/Library/Fonts.
          This will be fixed as soon as
          <link xlink:href="https://github.com/nix-community/home-manager/issues/155">home-manager#155</link>
          is closed.
        </para>
      </warning>
    '';
  };

  config = mkIf config.dotfiles.fonts.enable (mkMerge [
    (mkIf isGenericLinux {
      fonts.fontconfig.enable = mkDefault true;
    })
    (mkIf isDarwin {
      warnings = [
        ("Existing user fonts in ~/Library/Fonts may be overwritten. In most "
          + "cases, this just means that they would be replaced with the latest"
          + " versions of the same fonts.")
      ];

      home.activation = {
        copyFonts = hm.dag.entryAfter [ "writeBoundary" ] ''
          copyFonts() {
            local f
            find -L "${fonts}" -type f -print0 | while IFS= read -rd "" f; do
              install -Dm644 -t "$HOME/Library/Fonts" "$f"
            done
          }
          copyFonts
        '';
      };
    })
  ]);
}
