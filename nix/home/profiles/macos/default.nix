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
      linkApps.enable = lib.mkDefault false;
      copyApps.enable = lib.mkDefault true;

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

        "com.apple.finder" = {
          # enable desktop stacks
          DesktopViewSettings = {
            GroupBy = lib.mkDefault "Kind";
            IconViewSettings.arrangeBy = lib.mkDefault "dateAdded";
          };
          FXPreferredGroupBy = lib.mkDefault "Kind"; # somehow related to desktop stacking?
        };

        "com.apple.mail" = {
          SwipeAction = lib.mkDefault 1; # swipe to archive
          MailDockBadge = lib.mkDefault 1; # inbox only
          MailUserNotificationScope = lib.mkDefault 1; # inbox only
        };

        "com.apple.WindowManager" = {
          # Enable Stage Manager
          GloballyEnabled = lib.mkDefault true;
          GloballyEnabledEver = lib.mkDefault true;
          AppWindowGroupingBehavior = lib.mkDefault true; # show windows from an app all at once
          AutoHide = lib.mkDefault false; # show recent apps

          StandardHideDesktopIcons = lib.mkDefault false;
          HideDesktop = lib.mkDefault false;

          StandardHideWidgets = lib.mkDefault false;
          StageManagerHideWidgets = lib.mkDefault false;
        };
      };

      currentHostDefaults = {
        "com.apple.controlcenter" = {
          BatteryShowPercentage = lib.mkDefault true;
          Sound = lib.mkDefault 16; # always show in menu bar
          Spotlight = lib.mkDefault 8; # hide in menu bar
          Weather = lib.mkDefault 2; # show in menu bar
        };

        "com.apple.Spotlight".MenuItemHidden = lib.mkDefault true;
      };
    };
  };
}
