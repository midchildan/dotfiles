{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.dotfiles.profiles.macos;
in
{
  options.dotfiles.profiles.macos.swapCapsLockAndControl = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Whether to swap caps lock and control on the built-in keyboard.";
  };

  config = {
    targets.darwin = lib.mkIf cfg.enable {
      currentHostDefaults = {
        "Apple Global Domain" = lib.mkIf cfg.swapCapsLockAndControl {
          # Swap control and capslock for the built-in keyboard
          "com.apple.keyboard.modifiermapping.0-0-0" =
            let
              # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
              capslock = lib.fromHexString "700000039";
              lcontrol = lib.fromHexString "7000000e0";
              rcontrol = lib.fromHexString "7000000e4";
            in
            lib.mkDefault [
              {
                HIDKeyboardModifierMappingDst = capslock;
                HIDKeyboardModifierMappingSrc = lcontrol;
              }
              {
                HIDKeyboardModifierMappingDst = capslock;
                HIDKeyboardModifierMappingSrc = rcontrol;
              }
              {
                HIDKeyboardModifierMappingDst = rcontrol;
                HIDKeyboardModifierMappingSrc = capslock;
              }
            ];
        };
      };

      keybindings = {
        "^u" = lib.mkDefault "deleteToBeginningOfLine:";
        "^w" = lib.mkDefault "deleteWordBackward:";
      };
    };
  };
}
