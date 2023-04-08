{ inputs
, pkgs
, system
, packages
}:

{
  home = {
    type = "app";
    program = "${inputs.home.defaultPackage.${system}}/bin/home-manager";
  };

  update = {
    type = "app";
    program = "${pkgs.callPackage ./update.nix { }}";
  };

} // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {

  os = {
    type = "app";
    program = "${packages.nix-darwin}/bin/darwin-rebuild";
  };

} // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {

  os = {
    type = "app";
    program = "${packages.nixos-rebuild}/bin/nixos-rebuild";
  };
}
