{
  inputs,
  config,
  getSystem,
  ...
}@flake:

{
  imports = [ ./machines ];

  flake.nixosModules.default =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      imports = [ ./profiles ];

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
            `lib.mkNixOS`.
          '';
        };
      };

      config._module.args = {
        dotfiles = inputs.self;
        pkgsUnstable = (getSystem pkgs.stdenv.system).allModuleArgs.pkgs;
      };
    };
}
