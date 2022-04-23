{ inputs }: { lib, ... }:

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

  config = {
    _module.args.dotfiles = inputs.self;

    # NOTE: The following enables declarative management of the Nix user
    # registry using Home Manager. As a consequence, it makes the Nix registry
    # read-only, barring the 'nix registry' command from being able to
    # manipulate the Nix registry. If this is undesirable, disable declarative
    # management of the Nix registry by placing the following line in your
    # Home Manager configuration:
    #
    #     nix.registry = lib.mkForce { };
    nix.registry = {
      nixpkgs.flake = lib.mkDefault inputs.nixpkgs;
      dotfiles.flake = lib.mkDefault inputs.self;
    };
  };
}
