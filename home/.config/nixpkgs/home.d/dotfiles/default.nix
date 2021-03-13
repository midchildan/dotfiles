{ ... }:

{
  imports = [
    ./profiles
    ./news.nix
    ./modules/emacs.nix
    ./modules/launchd
    ./modules/linkapps.nix
    ./modules/manpages.nix
    ./modules/syncthing.nix
    ./modules/pinentry-mac.nix
  ];
}
