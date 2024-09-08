{
  inputs,
  config,
  getSystem,
  ...
}@flake:

{
  imports = [ ./machines ];

  flake.homeModules.default =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        ./modules
        ./profiles
        ./news.nix
      ];

      options.dotfiles = {
        flakeOptions = lib.mkOption {
          type = with lib.types; lazyAttrsOf anything;
          default = config.dotfiles._flakeOptions;
          readOnly = true;
          description = ''
            The flake-parts module options set for the dotfiles flake.
          '';
        };

        _flakeOptions = lib.mkOption {
          type = with lib.types; uniq (lazyAttrsOf anything);
          default = flake.config.dotfiles;
          internal = true;
          description = ''
            A writable proxy for the read-only {option}`dotfiles.flakeOptions`
            option. It's present to let downstream flakes set the option through
            `lib.mkHome`.
          '';
        };
      };

      config = {
        _module.args = {
          dotfiles = inputs.self;
          nixos = (getSystem pkgs.stdenv.system).allModuleArgs.nixos;
        };

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
        #     nix.channels = lib.mkForce { };
        nix.channels = {
          nixpkgs = lib.mkDefault inputs.nixpkgs;
          dotfiles = lib.mkDefault inputs.self;
        };
      };
    };
}
