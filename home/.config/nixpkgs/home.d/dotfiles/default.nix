{ ... }:

{
  imports = [
    ./profiles
    ./news.nix
    ./config/i18n.nix
    ./config/terminfo.nix
    ./modules/emacs.nix
    ./modules/fonts.nix
    ./modules/macos.nix
    ./modules/manpages.nix
    ./modules/pinentry-mac.nix
  ];
}
