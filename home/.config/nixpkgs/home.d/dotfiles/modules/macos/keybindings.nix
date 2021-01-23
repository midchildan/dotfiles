{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.dotfiles.macos;
  homeDir = config.home.homeDirectory;
  confFile = pkgs.writeText "DefaultKeybinding.dict"
    (lib.generators.toPlist { } cfg.keybindings);
in {
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

  config = mkIf (isDarwin && cfg.enable && cfg.keybindings != { }) {
    home.activation.macosKeybindings = hm.dag.entryAfter [ "writeBoundary" ] ''
      $VERBOSE_ECHO "Configuring keybindings for the Cocoa Text System"
      $DRY_RUN_CMD install -Dm644 $VERBOSE_ARG \
        "${confFile}" "${homeDir}/Library/KeyBindings/DefaultKeyBinding.dict"
    '';
  };
}
