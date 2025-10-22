{ config, ... }:

{
  perSystem =
    { pkgs, self', ... }:
    let
      nixAttrName = config.dotfiles.nix.package;
    in
    {
      apps.update.program = "${pkgs.callPackage ./update.nix {
        inherit (self') packages;
        nix = pkgs.nixVersions.${nixAttrName};
      }}";
    };
}
