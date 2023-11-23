{ inputs, config, ... }@flake:

{
  imports = [ ./machines ];

  flake.darwinModules.default = { lib, config, ... }: {
    imports = [
      ./modules/setup.nix
      ./modules/nix.nix
      ./modules/shell.nix
      ./profiles/common.nix
      ./profiles/apps.nix
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
      };
    };

    config._module.args.dotfiles = inputs.self;
  };
}
