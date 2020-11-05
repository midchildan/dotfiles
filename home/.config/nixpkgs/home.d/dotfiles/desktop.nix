{ config, pkgs, ... }:

{
  options.programs.dotfiles.desktop.enable =
    mkEnableOption "Essential packages for NixOS desktops";

  config = mkIf config.programs.dotfiles.desktop.enable {
    home.packages = with pkgs; [
      anki
      firefox-bin
      emacs
      gimp
      github-cli
      kitty
      libreoffice
      manpages
      sqlite # needed for org-roam w/ doom emacs
      virtmanager
      vlc
      vscode
      xclip

      # consider removing this and installing this system-wide instead
      emacs-all-the-icons-fonts
    ];
  };
}
