{ config, lib, ... }:

{
  options.dotfiles.profiles.apps.enable =
    lib.mkEnableOption "essential apps for Macs";

  config = lib.mkIf config.dotfiles.profiles.apps.enable {
    # Manage Homebrew with nix-darwin. Mainly useful for managing casks and
    # App Store installations. Any formula or cask not specified in the config
    # would be automatically uninstalled by default.
    homebrew = {
      enable = lib.mkDefault true;
      onActivation = {
        autoUpdate = lib.mkDefault true;
        upgrade = lib.mkDefault true;
        cleanup = lib.mkDefault "uninstall";
      };
    };

    homebrew.casks = [
      "alfred"
      "aquaskk"
      "firefox"
      "gimp"
      "gutenprint"
      "inkscape"
      "iterm2"
      "krita"
      "netnewswire"
      "skim"
      "wireshark"
    ];

    homebrew.masApps = {
      "1Blocker" = 1365531024;
    };
  };
}
