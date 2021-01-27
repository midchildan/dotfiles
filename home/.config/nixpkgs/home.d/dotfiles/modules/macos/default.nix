{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib.strings) escapeShellArg;

  cfg = config.dotfiles.macos;

  isFloat = x:
    isString x && builtins.match "^[+-]?([0-9]*[.])?[0-9]+$" x != null;

  isPlainAttrs = x: isAttrs x && isType "" x && (!isDerivation x);

  writeValue = val:
    if isBool val then
      "-bool ${if val then "TRUE" else "FALSE"}"
    else if isInt val then
      "-int ${toString val}"
    else if isFloat val then
      "-float ${toString val}"
    else if isString val then
      "-string ${escapeShellArg val}"
    else if (isList val && all isString val) then
      "-array ${concatMapStringsSep " " escapeShellArg val}"
    else if (isPlainAttrs val && all isString (attrValues val)) then
      "-dict ${
        concatStringsSep " "
        (flatten (mapAttrsToList (n: v: map escapeShellArg [ n v ]) val))
      }"
    else
      throw "invalid value type";

  writeDefault = domain: key: value:
    "$DRY_RUN_CMD defaults write ${escapeShellArg domain} ${
      escapeShellArg key
    } ${writeValue value}";

  defaultsToList = domain: attrs:
    mapAttrsToList (writeDefault domain) (filterAttrs (n: v: v != null) attrs);

  defaultsCommands = flatten (mapAttrsToList defaultsToList cfg.defaults);
in {
  imports = [ ./keybindings.nix ./linkapps.nix ./search.nix ];

  options.dotfiles.macos = {
    enable = mkEnableOption "macos settings";

    defaults = mkOption {
      type = types.submodule ./options.nix;
      default = { };
      example = {
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
      description = ''
        Set macOS user defaults. Some settings might require a re-login to take
        effect.
      '';
    };
  };

  config = mkIf (isDarwin && cfg.enable && cfg.defaults != { }) {
    home.activation.macosDefaults = hm.dag.entryAfter [ "writeBoundary" ] ''
      $VERBOSE_ECHO "Configuring macOS user defaults"
      ${concatStringsSep "\n" defaultsCommands}
    '';
  };
}
