{ config, lib, pkgs, ... }:

with lib;

{
  options.dotfiles.profiles.extras.enable =
    mkEnableOption "Extra nice to have packages";

  config = mkIf config.dotfiles.profiles.extras.enable {
    home.packages = with pkgs; [ exiftool ffmpeg-full nyancat youtube-dl ];
  };
}
