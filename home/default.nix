{ inputs }:

{
  imports = [
    ./profiles
    ./news.nix
    ./modules/gnupg
    ./modules/emacs.nix
    ./modules/firefox.nix
    ./modules/linkapps.nix
    ./modules/manpages.nix
    ./modules/syncthing.nix
    ./modules/userinfo.nix
    ./modules/vim.nix
  ];

  config._module.args.dotfiles = inputs.self;
}
