{ config, lib, pkgs, ... }:

with lib;

{
  options.dotfiles.profiles.extras.enable =
    mkEnableOption "extra nice to have packages";

  config = mkIf config.dotfiles.profiles.extras.enable {
    home.packages = with pkgs; [
      exiftool
      ffmpeg-full
      imagemagick
      nyancat
      ripgrep-all
      yt-dlp
    ];
  };
}
