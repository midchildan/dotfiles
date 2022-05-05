{ inputs }: { lib, config, ... }:

{
  imports = [
    ./profiles
    ./news.nix
    ./modules/gnupg
    ./modules/emacs.nix
    ./modules/firefox.nix
    ./modules/linkapps.nix
    ./modules/manpages.nix
    ./modules/nix.nix
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

    # NOTE: The following enables declarative management of Nix user channels
    # using Home Manager. Whatever channels defined using this mechanism takes
    # precendence over channels managed through the nix-channel command. If this
    # is undesirable, disable this by placing the following line in your Home
    # Manager configuration:
    #
    #     dotfiles.nix.nixPath = lib.mkForce [ ];
    dotfiles.nix.nixPath = [ "${config.xdg.dataHome}/dotfiles/nix-channels" ];

    xdg.dataFile = {
      "dotfiles/nix-channels/nixpkgs".source = inputs.nixpkgs.outPath;
      "dotfiles/nix-channels/dotfiles".source = inputs.self.outPath;
    };
  };
}
