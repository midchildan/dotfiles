{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  options.dotfiles.profiles.web.enable =
    lib.mkEnableOption "nice defaults for web browsers";

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
    };

    targets.darwin = lib.mkIf isDarwin {
      defaults."com.apple.Safari" = {
        AutoOpenSafeDownloads = lib.mkDefault false;
        AutoFillPasswords = lib.mkDefault false;
        AutoFillCreditCardData = lib.mkDefault false;
        IncludeDevelopMenu = lib.mkDefault true;
        ShowOverlayStatusBar = lib.mkDefault true;
      };

      search = lib.mkDefault "DuckDuckGo";
    };
  };
}
