{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.dotfiles.pinentry-mac;
  dstPath = "/usr/local/bin/pinentry-mac";
  extraPkgs = import ../pkgs { inherit pkgs; };
in {
  options.dotfiles.pinentry-mac.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Whether to install pinentry-mac. When enabled, this will install
      pinentry-mac to /usr/local/bin. This path was chosen instead of the Nix
      profile path because GnuPG's configuration requires the pinentry path to
      be specified as a single absolute path, somewhat complicating a smooth
      transition from Homebrew. Until a better solution can be found, this
      should work good enough for the time being.
    '';
  };

  config = mkIf isDarwin {
    # This verifies that /usr/local/bin/pinentry-mac is safe to overwrite, i.e.
    # doesn't point to a file outside of the Nix store.
    home.activation.checkPinentryMacTarget =
      hm.dag.entryBefore [ "writeBoundary" ] ''
        checkPinentryMacTarget() {
          [[ -z "${builtins.toString cfg.enable}" ]] && return
          [[ ! -e "${dstPath}" ]] && return

          exePath="$(readlink "${dstPath}")"
          realExe="$(readlink -m "${dstPath}")"

          if [[ "$exePath" != "${builtins.storeDir}"* ]]; then
            errorEcho "Existing file '$realExe' is in the way of '${dstPath}'"
            exit 1
          fi
        }

        checkPinentryMacTarget
      '';

    # This installs (or uninstalls) pinentry-mac to /usr/local/bin
    home.activation.linkPinentryMac = hm.dag.entryAfter [ "writeBoundary" ] ''
      linkPinentryMac() {
        if [[ -n "${builtins.toString cfg.enable}" ]]; then
          $VERBOSE_ECHO "Installing ${dstPath}"
          $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "${builtins.dirOf dstPath}"
          $DRY_RUN_CMD ln -nsf $VERBOSE_ARG \
            "${extraPkgs.pinentry_mac}/bin/pinentry-mac" \
            "${dstPath}"
          return
        fi

        [[ ! -e "${dstPath}" ]] && return
        exePath="$(readlink "${dstPath}")"

        if [[ "$exePath" == "${builtins.storeDir}"* ]]; then
          $VERBOSE_ECHO "Uninstalling ${dstPath}"
          $DRY_RUN_CMD rm $VERBOSE_ARG "${dstPath}"
        fi
      }

      linkPinentryMac
    '';
  };
}
