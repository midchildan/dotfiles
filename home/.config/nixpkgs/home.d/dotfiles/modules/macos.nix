{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib.strings) escapeShellArg;

  cfg = config.dotfiles.macos;
  homeDir = config.home.homeDirectory;

  isFloat = x:
    isString x && builtins.match "^[+-]?([0-9]*[.])?[0-9]+$" x != null;

  writeValue = value:
    if isBool value then
      "-bool ${if value then "TRUE" else "FALSE"}"
    else if isInt value then
      "-int ${toString value}"
    else if isFloat value then
      "-float ${toString value}"
    else if isString value then
      "-string ${escapeShellArg value}"
    else if (isList value && all isString value) then
      "-array ${concatMapStringsSep " " escapeShellArg value}"
    else
      throw "invalid value type";

  writeDefault = domain: key: value:
    "$DRY_RUN_CMD defaults write ${escapeShellArg domain} ${
      escapeShellArg key
    } ${writeValue value}";

  defaultsToList = domain: attrs:
    mapAttrsToList (writeDefault domain) (filterAttrs (n: v: v != null) attrs);

  defaultsCommands = flatten (mapAttrsToList defaultsToList cfg.defaults);

  confFile = pkgs.writeText "DefaultKeybinding.dict"
    (lib.generators.toPlist { } cfg.keybindings);
in {
  options.dotfiles.macos.enable = mkEnableOption "macos settings";

  options.dotfiles.macos.defaults = mkOption {
    type = with types; attrsOf attrs;
    default = { };
    example = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
    description = "Set macOS user defaults.";
  };

  options.dotfiles.macos.keybindings = mkOption {
    type = types.attrs;
    default = { };
    example = {
      "~f" = "moveWordForward:";
      "~b" = "moveWordBackward:";
    };
    description = ''
      Keybindings for the Cocoa Text System. See
      <link xlink:href="https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html">Apple's documentation</link>
      for more details.
    '';
  };

  config = mkIf (isDarwin && cfg.enable) (mkMerge [
    (mkIf (cfg.defaults != { }) {
      home.activation.macosDefaults = hm.dag.entryAfter [ "writeBoundary" ] ''
        $VERBOSE_ECHO "Configuring macOS user defaults"
        ${concatStringsSep "\n" defaultsCommands}
      '';
    })
    (mkIf (cfg.keybindings != { }) {
      home.activation.macosKeybindings =
        hm.dag.entryAfter [ "writeBoundary" ] ''
          $VERBOSE_ECHO "Configuring keybindings for the Cocoa Text System"
          $DRY_RUN_CMD install -Dm644 $VERBOSE_ARG \
            "${confFile}" "${homeDir}/Library/KeyBindings/DefaultKeyBinding.dict"
        '';
    })
  ]);
}
