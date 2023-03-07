{ inputs }:

{
  imports = [
    ./modules/config.nix
    ./profiles/apps.nix
  ];

  config._module.args.dotfiles = inputs.self;
}
