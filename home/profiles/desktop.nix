{ config, lib, pkgs, ... }:

let
  inherit (lib) mkDefault mkEnableOption mkIf optionals;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDir = config.home.homeDirectory;
in {
  options.dotfiles.profiles.desktop.enable =
    mkEnableOption "essential packages for desktop environemnts";

  config = mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      optionals isLinux [
        anki
        gimp
        ink
        kitty
        libreoffice
        lollypop
        vlc
        vscode
        xclip
      ];

    dotfiles.emacs.enable = mkDefault true;
    dotfiles.profiles.fonts.enable = mkDefault true;
    dotfiles.profiles.macos.enable = mkDefault isDarwin;

    dotfiles.firefox = {
      enable = mkDefault true;

      policies.Preferences = mkIf isLinux {
        # enable hardware accelerated video playback by default
        #
        # TODO: remove when this becomes the default
        # https://bugzilla.mozilla.org/show_bug.cgi?id=1777430
        "media.ffmpeg.vaapi.enabled" = {
          Value = mkDefault true;
          Status = mkDefault "default";
        };

        # enable swipe-to-navigate by default
        #
        # TODO: remove when this becomes the default
        # https://bugzilla.mozilla.org/buglist.cgi?product=Core&short_desc_type=allwordssubstr&query_format=advanced&short_desc=swipe&component=Panning%20and%20Zooming
        "widget.disable-swipe-tracker" = {
          Value = mkDefault false;
          Status = mkDefault "default";
        };
      };
    };
  };
}
