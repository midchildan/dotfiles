{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  options.dotfiles.profiles.macos.enable = lib.mkEnableOption "nice defaults for macOS preferences";

  imports = [ ./iterm2/profile.nix ];

  config = lib.mkIf config.dotfiles.profiles.macos.enable {

    targets.darwin = {
      defaults = {
        NSGlobalDomain = {
          # Locale
          AppleLanguages = lib.mkDefault [
            "en"
            "ja"
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
        };
      };

      currentHostDefaults = {
        "com.apple.controlcenter".BatteryShowPercentage = lib.mkDefault true;
      };

      keybindings = {
        "^u" = lib.mkDefault "deleteToBeginningOfLine:";
        "^w" = lib.mkDefault "deleteWordBackward:";
      };
    };

    dotfiles.aquaskk = {
      enable = lib.mkDefault true;
      config = {
        beep_on_registration = lib.mkDefault false;
        enable_annotation = lib.mkDefault true;
        enable_dynamic_completion = lib.mkDefault true;
        enable_extended_completion = lib.mkDefault true;
        show_input_mode_icon = lib.mkDefault true;
      };
      dictionaries = {
        "SKK-JISYO.L" = {
          type = "euc-jp";
          priority = 70;
          location = "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L";
        };
        "SKK-JISYO.propernoun" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.propernoun}/share/skk/SKK-JISYO.propernoun";
        };
        "SKK-JISYO.zipcode" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.zipcode}/share/skk/SKK-JISYO.zipcode";
        };
        "SKK-JISYO.office.zipcode" = {
          type = "euc-jp";
          location = "${pkgs.skkDictionaries.zipcode}/share/skk/SKK-JISYO.office.zipcode";
        };
        "SKK-JISYO.emoji" = {
          type = "utf-8";
          priority = 30;
          location = "${pkgs.skkDictionaries.emoji}/share/skk/SKK-JISYO.emoji";
        };
        program.type = "program";
      };
    };

    dotfiles.iterm2.settings = {
      "Default Bookmark Guid" = config.dotfiles.iterm2.profiles.home-manager.Guid;
      AddNewTabAtEndOfTabs = lib.mkDefault false;
      AllowClipboardAccess = lib.mkDefault true;
      AlternateMouseScroll = lib.mkDefault true;
      AlwaysAcceptFirstMouse = lib.mkDefault true;
      TabStyleWithAutomaticOption = 5;
      CopySelection = lib.mkDefault false;
      OpenTmuxWindowsIn = lib.mkDefault 2; # tabs in existing window

      # For AquaSKK
      #
      # This option is disabled by default in iTerm2 for supposed problems
      # with key repeats.
      #
      # https://github.com/gnachman/iTerm2/pull/279
      # https://gitlab.com/gnachman/iterm2/-/issues/6052
      ExperimentalKeyHandling = lib.mkDefault true;
    };
  };
}
