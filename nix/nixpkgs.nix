{ inputs, ... }@local:
{ lib, config, ... }:

let
  inherit (lib.types)
    attrsOf anything functionTo lazyAttrsOf listOf uniq unspecified;

  overlayType = uniq (functionTo (functionTo (lazyAttrsOf unspecified))) // {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
  };

  cfg = config.dotfiles.nixpkgs;
in
{
  options.dotfiles.nixpkgs.args = lib.mkOption {
    description = "The arguments to pass to Nixpkgs.";
    default = { };
    type = lib.types.submodule {
      freeformType = attrsOf anything;
      options = {
        config = lib.mkOption {
          type = attrsOf anything;
          description = "The Configuration for Nixpkgs.";
          default = import ../files/.config/nixpkgs/config.nix;
        };

        overlays = lib.mkOption {
          type = listOf overlayType;
          description = "List of overlays to use with Nixpkgs.";
          default = [ ];
        };
      };
    };
  };

  config.perSystem = { system, ... }:
    let
      mkPkgs = path: import path (cfg.args // {
        inherit system;
        overlays = [ inputs.self.overlays.default ] ++ cfg.args.overlays;
      });
    in
    {
      _module.args = {
        pkgs = mkPkgs inputs.nixpkgs;
        nixos = mkPkgs inputs.nixos;
      };
    };
}
