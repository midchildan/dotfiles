{ lib, config, ... }:

let
  nixAttrName = config.dotfiles.nix.package;
in
{
  perSystem = { pkgs, inputs', self', ... }: {
    apps = {
      home.program = "${inputs'.home.packages.default}/bin/home-manager";
      ansible.program = "${pkgs.callPackage ./ansible.nix { }}";
      update.program = "${pkgs.callPackage ./update.nix {
        inherit (self') packages;
        nix = pkgs.nixVersions.${nixAttrName};
      }}";

    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      os.program = "${self'.packages.nixos-rebuild}/bin/nixos-rebuild";

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      os.program = "${self'.packages.nix-darwin}/bin/darwin-rebuild";
    };
  };
}
