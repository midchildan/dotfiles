{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  homeDir = config.home.homeDirectory;
  fontsEnv = pkgs.buildEnv {
    name = "home-manager-fonts";
    paths = config.home.packages;
    pathsToLink = "/share/fonts";
  };
  fonts = "${fontsEnv}/share/fonts";
in {
  options.dotfiles.fonts.enable =
    mkEnableOption "font support for non-NixOS hosts";

  config = mkIf config.dotfiles.fonts.enable (mkMerge [
    (mkIf isGenericLinux { fonts.fontconfig.enable = mkDefault true; })
    (mkIf isDarwin {
      home.activation.copyFonts = hm.dag.entryAfter [ "writeBoundary" ] ''
        copyFonts() {
          rm -rf ${homeDir}/Library/Fonts/HomeManager

          local f
          find -L "${fonts}" -type f -printf '%P\0' | while IFS= read -rd "" f; do
            $DRY_RUN_CMD install $VERBOSE_ARG -Dm644 -T \
              "${fonts}/$f" "${homeDir}/Library/Fonts/HomeManager/$f"
          done
        }
        copyFonts
      '';
    })
  ]);
}
