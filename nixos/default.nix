{ inputs }:

{
  imports = [
    ./profiles/config.nix
    ./profiles/desktop.nix
    ./profiles/hardware.nix
    ./profiles/interactive.nix
    ./profiles/laptop.nix
    ./profiles/network.nix
  ];

  config._module.args.dotfiles = inputs.self;
}
