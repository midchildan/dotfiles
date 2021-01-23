{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDir = config.home.homeDirectory;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "essential packages for desktop environemnts";

  config = mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      optionals isLinux [
        anki
        firefox-bin
        gimp
        kitty
        libreoffice
        virtmanager
        vlc
        vscode
        xclip
      ] ++ optional isNixOS manpages;

    dotfiles.fonts.enable = mkDefault true;
    dotfiles.profiles.fonts.enable = mkDefault true;

    programs.emacs = {
      enable = mkDefault true;
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          pdf-tools
          vterm
        ];
    };

    dotfiles.emacs.extraConfig = ''
      (setq emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3")
    '';

    home.activation = mkIf config.programs.emacs.enable {
      rebuildDoomEmacs = hm.dag.entryAfter [ "installPackages" ] ''
        rebuildDoomEmacs() {
          local oldEmacs newEmacs
          oldEmacs="$(readlink -m "$oldGenPath/home-path/bin/emacs")"
          newEmacs="$(readlink -m "$newGenPath/home-path/bin/emacs")"
          if [[ "$newEmacs" == "$oldEmacs" ]]; then
            return
          fi
          if [[ -x "${homeDir}/.emacs.d/bin/doom" ]]; then
            $DRY_RUN_CMD "${homeDir}/.emacs.d/bin/doom" ''${VERBOSE:+-d} build \
              > /dev/null
          fi
        }
        rebuildDoomEmacs
      '';
    };

    dotfiles.macos = mkIf isDarwin {
      enable = mkDefault true;

      defaults = mkDefault {
        NSGlobalDomain = {
          # Locale
          AppleLanguages = [ "en" "ja" ];
          AppleLocale = "en_JP";
          AppleMeasurementUnits = "Centimeters";
          AppleMetricUnits = true;
          # Tame auto-correct
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
        };

        # Don't drop .DS_Store files all over the place
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.dock" = {
          tilesize = 32;
          size-immutable = true;
          expose-group-apps = true;
        };

        "com.apple.menuextra.battery".ShowPercent = "YES";

        "com.apple.Safari" = {
          AutoOpenSafeDownloads = false;
          AutoFillPasswords = false;
          AutoFillCreditCardData = false;
          IncludeDevelopMenu = true;
          ShowOverlayStatusBar = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" =
            true;
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
          AddNewTabAtEndOfTabs = false;
          AlternateMouseScroll = true;
          CopySelection = false;
          OpenTmuxWindowsIn = 2; # tabs in existing window

          # For AquaSKK
          #
          # This option is disabled by default in iTerm2 for supposed problems
          # with key repeats.
          #
          # https://github.com/gnachman/iTerm2/pull/279
          # https://gitlab.com/gnachman/iterm2/-/issues/6052
          ExperimentalKeyHandling = true;
        };
      };

      keybindings = mkDefault {
        "^u" = "deleteToBeginningOfLine:";
        "^w" = "deleteWordBackward:";
      };

      search = mkDefault "DuckDuckGo";
    };
  };
}
