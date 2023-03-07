{ inputs }: { pkgs, ... }:

let
  inherit (inputs.self.lib) mkPkgs;
  inherit (pkgs.stdenv) system;
in
{
  imports = [
    ./profiles/config.nix
    ./profiles/desktop.nix
    ./profiles/hardware.nix
    ./profiles/installer.nix
    ./profiles/interactive.nix
    ./profiles/laptop.nix
    ./profiles/network.nix
  ];

  config._module.args = {
    dotfiles = inputs.self;
    pkgsUnstable = mkPkgs inputs.nixpkgs { inherit system; };
  };
}
