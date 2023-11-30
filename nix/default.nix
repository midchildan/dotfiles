{ flake-parts-lib, inputs, ... }:

let
  inherit (flake-parts-lib) importApply;

  flakeModules.default = {
    imports = [
      (importApply ./config.nix { inherit inputs; })
      (importApply ./nixpkgs.nix { inherit inputs; })
      (importApply ./lib { inherit inputs; })
    ];
  };
in
{
  imports = [
    flakeModules.default
    inputs.flake-parts.flakeModules.flakeModules
    ./apps
    ./darwin
    ./devshells
    ./home
    ./nixos
    ./overlays
    ./packages
    ./templates
  ];

  flake = {
    inherit flakeModules;
  };

  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixpkgs-fmt;
  };
}
