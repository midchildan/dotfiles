{ flake-parts-lib, lib, config, ... }:

let
  inherit (flake-parts-lib) importApply;
  nixAttrName = config.dotfiles.nix.package;

  flakeModules.updater = {
    imports = [
      (importApply ./flake-modules.nix { inherit config; })
    ];
  };
in
{
  imports = [ flakeModules.updater ];

  flake = {
    inherit flakeModules;
  };

  perSystem = { pkgs, inputs', self', ... }: {
    apps = {
      home.program = "${inputs'.home.packages.default}/bin/home-manager";
      ansible.program = "${pkgs.callPackage ./ansible.nix { }}";

    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      os.program = "${self'.packages.nixos-rebuild}/bin/nixos-rebuild";

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      os.program = "${self'.packages.nix-darwin}/bin/darwin-rebuild";
    };
  };
}
