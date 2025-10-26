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

  uboLite = "ddkjiahejlhfcafbddmgiahcphecmpfh";
  chromeExtensions = [
    # uBlock Origin Lite
    uboLite
    # SponsorBlock
    "mnjggcdmjocbbbhaepdhchncahnbgone"
  ];
in
{
  options.dotfiles.profiles.web.enable = lib.mkEnableOption "nice defaults for web browsers";

  config = lib.mkIf config.dotfiles.profiles.web.enable {
    dotfiles.firefox = {
      enable = lib.mkDefault true;
      preferences = {
        # Setting via policy is forbidden for now
        # "sidebar.revamp" = lib.mkDefault true;
        # "sidebar.verticalTabs" = lib.mkDefault true;
      };

      policies = {
        DisableFirefoxStudies = lib.mkDefault true;
        DisableTelemetry = lib.mkDefault true;
        DontCheckDefaultBrowser = lib.mkDefault true;
        EnableTrackingProtection = {
          Category = lib.mkDefault "strict";
          # NOTE: Currently, the following two policies are ignored when category is set.
          # https://searchfox.org/firefox-main/rev/c2646728/browser/components/enterprisepolicies/Policies.sys.mjs#1226-1229
          BaselineExceptions = lib.mkDefault true;
          ConvenienceExceptions = lib.mkDefault true;
        };
        EncryptedMediaExtensions.Enabled = lib.mkDefault true;
        SearchEngines.Default = lib.mkDefault "DuckDuckGo";
      };

      policies.ExtensionSettings =
        lib.mapAttrs
          (
            name: value:
            {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/${lib.escapeURL name}/latest.xpi";
              default_area = lib.mkDefault "menupanel";
            }
            // value
          )
          {
            # Firefox Multi-Account Containers
            "@testpilot-containers" = {
              default_area = lib.mkDefault "navbar";
            };

            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              private_browsing = lib.mkDefault true;
            };

            # SponsorBlock
            "sponsorBlocker@ajay.app" = { };

            # Ruffle
            "{b5501fd1-7084-45c5-9aa6-567c2fcf5dc6}" = { };
          };

      policies."3rdparty".Extensions = {
        # See:
        # https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin:-configuration
        # https://raw.githubusercontent.com/gorhill/uBlock/refs/heads/master/platform/common/managed_storage.json
        "uBlock0@raymondhill.net" = {
          # Obtain the default lists with:
          # curl -sSfL https://raw.githubusercontent.com/gorhill/uBlock/refs/heads/master/assets/assets.json \
          #   | jq -r 'to_entries[] | select(.value | .content == "filters" and (.off | not)) | .key'
          toOverwrite.filterLists = lib.mkDefault [
            # default
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-unbreak"
            "ublock-quick-fixes"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
            # added
            "block-lan"
            "fanboy-cookiemonster"
            "fanboy-social"
            "ublock-annoyances"
            "JPN-1"
            "easylist-annoyances"
            "easylist-chat"
            "easylist-newsletters"
            "easylist-notifications"
            "ublock-cookies-easylist"
          ];
        };
      };
    };

    targets.darwin = lib.mkIf isDarwin {
      defaults = {
        "com.apple.Safari" = {
          AlwaysRestoreSessionAtLaunch = lib.mkDefault true;
          ExcludePrivateWindowWhenRestoringSessionAtLaunch = lib.mkDefault true;
          AutoOpenSafeDownloads = lib.mkDefault false;
          AutoFillPasswords = lib.mkDefault false;
          AutoFillCreditCardData = lib.mkDefault false;
          IncludeDevelopMenu = lib.mkDefault true;
          ShowOverlayStatusBar = lib.mkDefault true;
        };
        "com.apple.Safari.SandboxBroker".ShowDevelopMenu = lib.mkDefault true;

        # The configuration here is only for macOS. On Linux, Chrome doesn't appear to support OS
        # user level policies, so policies would have to be set at the system level.
        #
        # Also numerous policies are enterprise only according to the docs. Examples include
        # telemetry opt-out.
        # https://chromeenterprise.google/intl/en_us/policies/#MetricsReportingEnabled
        "com.google.Chrome" = {
          RestoreOnStartup = lib.mkDefault 1; # restore the last session
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

          # > On macOS, this policy is only available on instances that are managed via MDM, joined
          # > to a domain via MCX or enrolled in Chrome Enterprise Core.
          # https://chromeenterprise.google/intl/en_us/policies/?policy=DefaultSearchProviderEnabled
          DefaultSearchProviderEnabled = lib.mkDefault true;
          DefaultSearchProviderName = lib.mkDefault "DuckDuckGo";
          DefaultSearchProviderKeyword = lib.mkDefault "ddg";
          DefaultSearchProviderSearchURL = lib.mkDefault "https://start.duckduckgo.com/?q={searchTerms}";
          DefaultSearchProviderSuggestURL = lib.mkDefault "https://start.duckduckgo.com/ac/?q={searchTerms}&type=list";
          DefaultSearchProviderNewTabURL = lib.mkDefault "https://start.duckduckgo.com/chrome_newtab";

          ManagedBookmarks = [
            # Non-enterprise users have to change search engines manually, so at least make it easy.
            {
              name = "Search engine settings";
              url = "chrome://settings/search";
            }
          ];
        };

        # https://github.com/uBlockOrigin/uBOL-home/wiki/Managed-settings
        "com.google.Chrome.extensions.${uboLite}" = {
          defaultFiltering = lib.mkDefault "complete";

          # Obtain non-default rulesets with:
          # curl -sSfL https://raw.githubusercontent.com/uBlockOrigin/uBOL-home/refs/heads/main/chromium/rulesets/ruleset-details.json \
          #   | jq -r '.[] | select(.enabled | not) | .id'
          rulesets = [
            "+default"
            "+block-lan"
            "+annoyances-cookies"
            "+annoyances-overlays"
            "+annoyances-social"
            "+annoyances-widgets"
            "+annoyances-others"
            "+annoyances-notifications"
            "+jpn-1"
          ];
        };
      };

      search = lib.mkDefault "DuckDuckGo";
    };

    # Install extensions
    # https://developer.chrome.com/docs/extensions/how-to/distribute/install-extensions
    home.file = lib.mkIf isDarwin (
      let
        pathFor = id: "Library/Application Support/Google/Chrome/External Extensions/${id}.json";
        paths = map pathFor chromeExtensions;
        content = {
          text = builtins.toJSON {
            external_update_url = "https://clients2.google.com/service/update2/crx";
          };
        };
      in
      lib.genAttrs paths (_: content)
    );
  };
}
