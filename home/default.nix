{ inputs }:

{
  imports = [
    ./profiles
    ./news.nix
    ./modules/emacs.nix
    ./modules/firefox.nix
    ./modules/launchd
    ./modules/linkapps.nix
    ./modules/manpages.nix
    ./modules/syncthing.nix
    ./modules/pinentry-mac.nix
    ./modules/userinfo.nix
    ./modules/vim.nix
  ];

  config._module.args.dotfiles = inputs.self;
}
