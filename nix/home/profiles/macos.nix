{ config, lib, pkgs, dotfiles, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf;
  inherit (pkgs.stdenv.hostPlatform) system;
  myPkgs = dotfiles.packages.${system};
in
{
  options.dotfiles.profiles.macos.enable =
    mkEnableOption "nice defaults for macOS preferences";

  config = mkIf config.dotfiles.profiles.macos.enable {
    targets.darwin = {
      defaults = {
        NSGlobalDomain = {
          # Locale
          AppleLanguages = mkDefault [ "en" "ja" ];
          AppleLocale = mkDefault "en_JP";
          AppleMeasurementUnits = mkDefault "Centimeters";
          AppleMetricUnits = mkDefault true;
          # Tame auto-correct
          NSAutomaticCapitalizationEnabled = mkDefault false;
          NSAutomaticDashSubstitutionEnabled = mkDefault false;
          NSAutomaticPeriodSubstitutionEnabled = mkDefault false;
          NSAutomaticQuoteSubstitutionEnabled = mkDefault false;
          NSAutomaticSpellingCorrectionEnabled = mkDefault false;
        };

        # Don't drop .DS_Store files all over the place
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = mkDefault true;
          DSDontWriteUSBStores = mkDefault true;
        };

        "com.apple.dock" = {
          tilesize = mkDefault 32;
          size-immutable = mkDefault true;
          expose-group-apps = mkDefault true;
        };

        # NOTE: Settings under "Preferences > Profiles" aren't covered here. To
        # obtain a more complete iTerm2 configuration, copy settings from the
        # "Template" profile included in this dotfiles. Assuming this dotfiles
        # is already installed, this can be done with the following steps:
        #
        #   1. Open "Preferences > Profiles"
        #   2. Select "Template" from the list of profiles on the left
        #   3. Click "Other Actions > Bulk Copy from Selected Profile"
        #   4. Specify which configuration to copy (recommended: all)
        #   5. Select the target profile (recommended: "Default")
        #   6. Click "Copy" to confirm
        "com.googlecode.iterm2" = {
          AddNewTabAtEndOfTabs = mkDefault false;
          AllowClipboardAccess = mkDefault true;
          AlternateMouseScroll = mkDefault true;
          AlwaysAcceptFirstMouse = mkDefault true;
          TabStyleWithAutomaticOption = 5;
          CopySelection = mkDefault false;
          OpenTmuxWindowsIn = mkDefault 2; # tabs in existing window

          # For AquaSKK
          #
          # This option is disabled by default in iTerm2 for supposed problems
          # with key repeats.
          #
          # https://github.com/gnachman/iTerm2/pull/279
          # https://gitlab.com/gnachman/iterm2/-/issues/6052
          ExperimentalKeyHandling = mkDefault true;
        };
      };

      currentHostDefaults = {
        "com.apple.controlcenter".BatteryShowPercentage = mkDefault true;
      };

      keybindings = {
        "^u" = mkDefault "deleteToBeginningOfLine:";
        "^w" = mkDefault "deleteWordBackward:";
      };
    };

    dotfiles.aquaskk = {
      enable = mkDefault true;
      config = {
        beep_on_registration = mkDefault false;
        enable_annotation = mkDefault true;
        enable_dynamic_completion = mkDefault true;
        enable_extended_completion = mkDefault true;
        show_input_mode_icon = mkDefault true;
      };
      dictionaries = {
        "SKK-JISYO.L" = {
          type = "euc-jp";
          priority = 70;
          location = "${myPkgs.skk-jisyo-l}/share/skk/SKK-JISYO.L";
        };
        "SKK-JISYO.propernoun" = {
          type = "euc-jp";
          location = "${myPkgs.skk-jisyo-propernoun}/share/skk/SKK-JISYO.propernoun";
        };
        "SKK-JISYO.zipcode" = {
          type = "euc-jp";
          location = "${myPkgs.skk-jisyo-zipcode}/share/skk/SKK-JISYO.zipcode";
        };
        "SKK-JISYO.office.zipcode" = {
          type = "euc-jp";
          location = "${myPkgs.skk-jisyo-zipcode}/share/skk/SKK-JISYO.office.zipcode";
        };
        "SKK-JISYO.emoji" = {
          type = "utf-8";
          priority = 30;
          location = "${myPkgs.skk-jisyo-emoji}/share/skk/SKK-JISYO.emoji";
        };
        program.type = "program";
      };
    };
  };
}
