{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dotfiles.profiles.extras.enable = lib.mkEnableOption "extra nice to have packages";

  config = lib.mkIf config.dotfiles.profiles.extras.enable {
    home.packages = with pkgs; [
      exiftool
      ffmpeg-headless
      imagemagick
      nyancat
      ripgrep-all
      yt-dlp
    ];
  };
}
