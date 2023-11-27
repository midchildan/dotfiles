{ lib, ... }:

{
  perSystem = { pkgs, inputs', self', ... }: {
    apps = {
      home.program = "${inputs'.home.packages.default}/bin/home-manager";
      update.program = "${pkgs.callPackage ./update.nix { }}";
      ansible.program = "${pkgs.callPackage ./ansible.nix { }}";

    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      os.program = "${self'.packages.nixos-rebuild}/bin/nixos-rebuild";

    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      os.program = "${self'.packages.nix-darwin}/bin/darwin-rebuild";
    };
  };
}
