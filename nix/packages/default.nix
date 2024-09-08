{ config, inputs, ... }:

{
  perSystem =
    { pkgs, nixos, ... }:
    {
      dotfiles.callPackages = {
        enable = true;
        directory = ./by-name;
      };

      dotfiles.callPackages.extraPackages = ps: {
        nixos-iso = nixos.callPackage ./by-name/nixos-iso.nix {
          inherit nixos;
          inherit (inputs.self.lib) mkNixOS;
          modules = [ ];
        };

        nixos-rebuild = nixos.callPackage ./by-name/nixos-rebuild.nix {
          nix = pkgs.nixVersions.${config.dotfiles.nix.package};
        };

        skk-jisyo = ps.callPackages ./by-name/skk-jisyo.nix { };

        zsh = ps.callPackage ./by-name/zsh.nix { inherit (pkgs) zsh; };
      };
    };
}
