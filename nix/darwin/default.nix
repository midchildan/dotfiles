{ inputs }:

{
  imports = [
    ./modules/nix.nix
    ./modules/shell.nix
    ./profiles/apps.nix
  ];

  config._module.args.dotfiles = inputs.self;
}
