{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:

let
  inherit (flake-parts-lib) importApply;

  flakeModules = {
    default.imports = [
      (importApply ./config.nix { inherit inputs; })
      (importApply ./nixpkgs.nix { inherit inputs; })
      (importApply ./lib/flake-module.nix { inherit inputs; })
    ];
    checks = ./checks.nix;
    style = ./style.nix;
  };
in
{
  imports = lib.attrValues flakeModules ++ [
    inputs.flake-parts.flakeModules.flakeModules
    ./apps
    ./darwin
    ./devshells
    ./home
    ./lib
    ./nixos
    ./overlays
    ./packages
    ./templates
  ];

  flake = {
    inherit flakeModules;
  };
}
