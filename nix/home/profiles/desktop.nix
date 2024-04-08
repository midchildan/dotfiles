{ config, lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  options.dotfiles.profiles.desktop.enable =
    lib.mkEnableOption "essential packages for desktop environemnts";

  config = lib.mkIf config.dotfiles.profiles.desktop.enable {
    home.packages = with pkgs;
      lib.optionals isLinux [
        anki
        gimp
        ink
        kitty
        libreoffice
        lollypop
        xclip
      ];

    programs.mpv = {
      enable = lib.mkDefault true;
      config = {
        profile = lib.mkDefault "fast"; # trade quality for power efficiency
        autofit-larger = lib.mkDefault "100%x100%";
        hwdec = lib.mkDefault "auto";
        keep-open = lib.mkDefault true;
      };
      profiles = {
        "protocol.https" = {
          # use a format friendly to hardware decoders
          ytdl-format = lib.mkDefault "mp4[height<=?720]";
        };
        "protocol.http".profile = lib.mkDefault "protocol.https";
      };
    };

    dotfiles.emacs.enable = lib.mkDefault true;
    dotfiles.profiles = {
      fonts.enable = lib.mkDefault true;
      macos.enable = lib.mkDefault isDarwin;
      web.enable = lib.mkDefault true;
    };
  };
}
