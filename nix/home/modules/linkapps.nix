{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf hm;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  destination = "${config.home.homeDirectory}/Applications/Home Manager";

  apps = pkgs.buildEnv {
    name = "home-manager-applications";
    paths = config.home.packages;
    pathsToLink = "/Applications";
  };
in
{
  # Disable Home Manager's built-in app linking. The built-in one uses
  # symlinks, which won't be picked up by Spotlight.
  disabledModules = [ "targets/darwin/linkapps.nix" ];

  config = mkIf isDarwin {
    home.activation.linkMacOSApplications = hm.dag.entryAfter [ "writeBoundary" ] ''
      linkMacOSApplications() {
        $VERBOSE_ECHO 'Creating aliases for macOS Applications'
        $DRY_RUN_CMD rm -rf $VERBOSE_ARG '${destination}'
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG '${destination}'

        local app app_path
        find -L "${apps}/Applications" -mindepth 1 -maxdepth 1 -type d -print0 \
            | while IFS= read -rd "" app; do
          if ! app_path="$(realpath -e "$app")"; then
            continue
          fi

          $DRY_RUN_CMD /usr/bin/osascript \
            -e 'tell app "Finder"' \
            -e "make new alias file at POSIX file \"${destination}\" to POSIX file \"$app_path\"" \
            -e "set name of result to \"''${app_path##*/}\"" \
            -e 'end tell'
        done
      }
      linkMacOSApplications
    '';
  };
}
