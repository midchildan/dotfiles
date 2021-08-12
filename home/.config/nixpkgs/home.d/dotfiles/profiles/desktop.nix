{ config, lib, pkgs, ... }:

with lib;

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  homeDir = config.home.homeDirectory;
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
        lollypop
        virtmanager
        vlc
        vscode
        xclip
      ];

    dotfiles.profiles.fonts.enable = mkDefault true;

    programs.emacs = {
      enable = mkDefault true;
      extraConfig = ''
        (setq dired-use-ls-dired t
              emacsql-sqlite3-executable "${pkgs.sqlite}/bin/sqlite3"
              insert-directory-program "${pkgs.coreutils}/bin/ls"
              treemacs-python-executable "${pkgs.python3}/bin/python")
      '';
      extraPackages = epkgs:
        with epkgs; [
          # include Doom Emacs dependencies that tries to build native C code
          pdf-tools
          vterm
        ];
    };

    home.activation = mkIf config.programs.emacs.enable {
      rebuildDoomEmacs = hm.dag.entryAfter [ "installPackages" ] ''
        rebuildDoomEmacs() {
          local oldEmacs newEmacs
          oldEmacs="$(readlink -m "$oldGenPath/home-path/bin/emacs")"
          newEmacs="$(readlink -m "$newGenPath/home-path/bin/emacs")"
          if [[ "$newEmacs" == "$oldEmacs" ]]; then
            return
          fi
          if [[ -x "${homeDir}/.config/emacs/bin/doom" ]]; then
            $DRY_RUN_CMD "${homeDir}/.config/emacs/bin/doom" \
              ''${VERBOSE:+-d} build > /dev/null
          fi
        }
        rebuildDoomEmacs
      '';
    };

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

        "com.apple.menuextra.battery".ShowPercent = mkDefault "YES";

        "com.apple.Safari" = {
          AutoOpenSafeDownloads = mkDefault false;
          AutoFillPasswords = mkDefault false;
          AutoFillCreditCardData = mkDefault false;
          IncludeDevelopMenu = mkDefault true;
          ShowOverlayStatusBar = mkDefault true;
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
          AlternateMouseScroll = mkDefault true;
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

      keybindings = {
        "^u" = mkDefault "deleteToBeginningOfLine:";
        "^w" = mkDefault "deleteWordBackward:";
      };

      search = mkDefault "DuckDuckGo";
    };
  };
}
