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
  options.dotfiles.profiles.macos.enable = lib.mkEnableOption "nice defaults for macOS preferences";

  imports = [
    ./aquaskk.nix
    ./keyboard.nix
    ./iterm2
  ];

  config = lib.mkIf cfg.enable {
    targets.darwin = {
      defaults = {
        NSGlobalDomain = {
          # Locale
          AppleLanguages = lib.mkDefault [
            "en-US"
            "ja-JP"
          ];
          AppleLocale = lib.mkDefault "en_JP";
          AppleMeasurementUnits = lib.mkDefault "Centimeters";
          AppleMetricUnits = lib.mkDefault true;
          # Tame auto-correct
          NSAutomaticCapitalizationEnabled = lib.mkDefault false;
          NSAutomaticDashSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticPeriodSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticQuoteSubstitutionEnabled = lib.mkDefault false;
          NSAutomaticSpellingCorrectionEnabled = lib.mkDefault false;
        };

        # Don't drop .DS_Store files all over the place
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = lib.mkDefault true;
          DSDontWriteUSBStores = lib.mkDefault true;
        };

        "com.apple.dock" = {
          tilesize = lib.mkDefault 32;
          size-immutable = lib.mkDefault true;
          expose-group-apps = lib.mkDefault true;
          showAppExposeGestureEnabled = lib.mkDefault true;
        };

        "com.apple.mail".SwipeAction = lib.mkDefault 1; # swipe to archive
      };

      currentHostDefaults = {
        "com.apple.controlcenter".BatteryShowPercentage = lib.mkDefault true;
      };
    };
  };
}
