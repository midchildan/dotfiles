# Configure web browsers. Installation is out of scope here because I have different web browser
# installation strategies on different machines. I also don't even install all of the browsers
# configured here on every machine I use.

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  chromeExtensions = [
    rec {
      name = "uBlock Origin Lite";
      id = "ddkjiahejlhfcafbddmgiahcphecmpfh";
      url = "https://chromewebstore.google.com/detail/ublock-origin-lite/${id}";
    }
    rec {
      name = "SponsorBlock";
      id = "mnjggcdmjocbbbhaepdhchncahnbgone";
      url = "https://chromewebstore.google.com/detail/sponsorblock-for-youtube/${id}";
    }
  ];
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

        # The configuration here is only for macOS. On Linux, Chrome doesn't appear to support OS
        # user level policies, so policies would have to be set at the system level.
        "com.google.Chrome" = {
          RestoreOnStartup = 1; # restore the last session
          PasswordManagerEnabled = lib.mkDefault false;

          AdsSettingForIntrusiveAdsSites = lib.mkDefault 2; # disallow
          BlockThirdPartyCookies = lib.mkDefault true;
          BrowserSignin = lib.mkDefault 0; # disable
          DefaultBrowserSettingEnabled = lib.mkDefault false;
          GenAiDefaultSettings = lib.mkDefault 2; # 1: allow but no training, 2: disallow
          MetricsReportingEnabled = lib.mkDefault false;
          PrivacySandboxAdMeasurementEnabled = lib.mkDefault false;
          PrivacySandboxSandboxAdTopicsEnabled = lib.mkDefault false;
          PrivacySandboxPromptEnabled = lib.mkDefault false;
          PrivacySandboxSiteEnabledAdsEnabled = lib.mkDefault false;
          SyncDisabled = lib.mkDefault true;

          DefaultSearchProviderEnabled = lib.mkDefault true;
          DefaultSearchProviderName = lib.mkDefault "DuckDuckGo";
          DefaultSearchProviderKeyword = lib.mkDefault "ddg";
          DefaultSearchProviderSearchURL = lib.mkDefault "https://start.duckduckgo.com/?q={searchTerms}";
          DefaultSearchProviderSuggestURL = lib.mkDefault "https://start.duckduckgo.com/ac/?q={searchTerms}&type=list";
          DefaultSearchProviderNewTabURL = lib.mkDefault "https://start.duckduckgo.com/chrome_newtab";

          # If a system wide policy already includes these settings, they'll unfortunately be
          # overriden instead of being merged.
          ExtensionInstallForceList = map (e: e.id) chromeExtensions;
          ManagedBookmarks = map (e: { inherit (e) name url; }) chromeExtensions;
        };
      };

      search = lib.mkDefault "DuckDuckGo";
    };
  };
}
