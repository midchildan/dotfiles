{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  options.dotfiles.profiles.web.enable = lib.mkEnableOption "nice defaults for web browsers";

  config = lib.mkIf config.dotfiles.profiles.web.enable {
    dotfiles.firefox = {
      enable = lib.mkDefault true;
      preferences = lib.mkIf isLinux {
        # enable hardware accelerated video playback by default
        #
        # TODO: remove when this becomes the default
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1777430
        "media.ffmpeg.vaapi.enabled" = lib.mkDefault true;

        # enable swipe-to-navigate by default
        #
        # TODO: remove when this becomes the default
        # https://bugzilla.mozilla.org/buglist.cgi?product=Core&short_desc_type=allwordssubstr&query_format=advanced&short_desc=swipe&component=Panning%20and%20Zooming
        "widget.disable-swipe-tracker" = lib.mkDefault false;
      };

      policies.Preferences."browser.contentblocking.category" = {
        Value = lib.mkDefault "strict";

        # Firefox forcibly sets this option to "custom" if:
        #   1. The setting doesn't appear to be set by the user
        #   2. Related settings deviate from the expected values
        # https://searchfox.org/mozilla-central/rev/201b2c1/browser/components/BrowserGlue.jsm#5059
        Status = lib.mkDefault "user";
      };
    };

    targets.darwin = lib.mkIf isDarwin {
      defaults = {
        "com.apple.Safari" = {
          AutoOpenSafeDownloads = lib.mkDefault false;
          AutoFillPasswords = lib.mkDefault false;
          AutoFillCreditCardData = lib.mkDefault false;
          IncludeDevelopMenu = lib.mkDefault true;
          ShowOverlayStatusBar = lib.mkDefault true;
        };
        "com.apple.Safari.SandboxBroker".ShowDevelopMenu = lib.mkDefault true;
      };

      search = lib.mkDefault "DuckDuckGo";
    };
  };
}
