{ config, lib, pkgs, ... }:

with lib;

let extraPkgs = import ../pkgs { inherit pkgs; };
in {
  options.dotfiles.profiles.fonts.enable = mkOption {
    type = types.bool;
    default = config.dotfiles.profiles.desktop.enable;
    description = ''
      Whether to install recommended fonts. Disable this if you prefer to
      install fonts through the system.
    '';
  };

  config = mkIf config.dotfiles.profiles.fonts.enable {
    dotfiles.fonts.enable = mkDefault true;

    home.packages = with pkgs; [
      xkcd-font
      emacs-all-the-icons-fonts
    ] ++ (with extraPkgs; [
      fira-code
      powerline-symbols
    ]);
  };
}
