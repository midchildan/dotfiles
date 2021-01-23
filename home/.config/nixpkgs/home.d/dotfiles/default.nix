{ ... }:

{
  imports = [
    ./profiles
    ./news.nix
    ./config/i18n.nix
    ./config/terminfo.nix
    ./modules/emacs.nix
    ./modules/fonts.nix
    ./modules/launchd
    ./modules/macos
    ./modules/manpages.nix
    ./modules/syncthing.nix
    ./modules/pinentry-mac.nix
  ];
}
