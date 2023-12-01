{ config }@localFlake:
{ ... }@flake:

let
  nixAttrName = config.dotfiles.nix.package;
in
{
  perSystem = { pkgs, self', ... }: {
    apps.update.program = "${pkgs.callPackage ./update.nix {
      inherit (self') packages;
      nix = pkgs.nixVersions.${nixAttrName};
    }}";
  };
}
