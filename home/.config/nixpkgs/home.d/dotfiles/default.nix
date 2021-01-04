{ ... }:

{
  imports = [
    ./profiles
    ./news.nix
    ./config/i18n.nix
    ./config/terminfo.nix
    ./modules/emacs.nix
    ./modules/manpages.nix
    ./modules/pinentry-mac.nix
  ];
}
