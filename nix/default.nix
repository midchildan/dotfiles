{ lib
, flake-parts-lib
, inputs
, ...
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
  };
in
{
  imports = lib.attrValues flakeModules ++ [
    inputs.flake-parts.flakeModules.flakeModules
    inputs.treefmt-nix.flakeModule
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

  perSystem =
    { pkgs, ... }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixpkgs-fmt.enable = true;
          shellcheck.enable = true;
          prettier = {
            enable = true;
            settings.proseWrap = "always";
          };
        };
        settings.formatter.shellcheck.options = [
          "--external-sources"
          "--source-path=SCRIPTDIR"
        ];
      };
    };
}
