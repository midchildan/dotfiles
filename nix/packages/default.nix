{ config, inputs, ... }:

{
  perSystem =
    { pkgs, pkgsStable, ... }:
    {
      dotfiles.callPackages = {
        enable = true;
        directory = ./by-name;
      };

      dotfiles.callPackages.extraPackages = ps: {
        nixos-iso = pkgsStable.callPackage ./by-name/nixos-iso.nix {
          inherit pkgsStable;
          inherit (inputs.self.lib) mkNixOS;
          modules = [ ];
        };

        nixos-rebuild = pkgsStable.callPackage ./by-name/nixos-rebuild.nix {
          nix = pkgs.nixVersions.${config.dotfiles.nix.package};
        };

        zsh = ps.callPackage ./by-name/zsh.nix { inherit (pkgs) zsh; };
      };
    };
}
