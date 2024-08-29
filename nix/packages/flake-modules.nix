{ inputs }@localFlake:
{
  lib,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (inputs.self.lib) collectPackages;
in
{
  options.perSystem = mkPerSystemOption {
    options.dotfiles.callPackages = {
      enable = lib.mkEnableOption "imports of all packages defined in the specified directory";

      directory = lib.mkOption {
        description = "The directory from which packages should be imported.";
        type = lib.types.path;
      };

      extraPackages = lib.mkOption {
        description = "Additional packages to include in the package set.";
        type = with lib.types; functionTo (lazyAttrsOf anything);
        default = self: { };
        defaultText = lib.literalExpression "self: {}";
        example = lib.literalExpression ''
          self: {
            foo = self.callPackage ./foo { stdenv = clangStdenv; };
          }
        '';
      };
    };
  };

  config.perSystem =
    { config, pkgs, ... }:
    let
      cfg = config.dotfiles.callPackages;
    in
    lib.mkIf cfg.enable {
      packages = collectPackages {
        inherit pkgs;
        inherit (cfg) directory;
      } cfg.extraPackages;
    };
}
