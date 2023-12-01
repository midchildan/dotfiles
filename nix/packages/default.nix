{ lib, inputs, config, ... }:

{
  perSystem = { pkgs, nixos, ... }:
    let
      inherit (pkgs.stdenv) isDarwin isLinux;
      nix = pkgs.nixVersions.${config.dotfiles.nix.package};
    in
    {
      packages = rec {

        cloudfoundry-cli-6 =
          pkgs.callPackage ./cloudfoundry-cli/default.nix { };
        mmdbctl = pkgs.callPackage ./mmdbctl.nix { };
        neovim = pkgs.callPackage ./neovim.nix { };
        terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

        coc-ansible = pkgs.callPackage ./coc-ansible.nix {
          inherit (pkgs.vimUtils) buildVimPlugin;
        };

      } // lib.optionalAttrs isLinux {

        bpftrace = nixos.callPackage ./bpftrace.nix { };
        nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { inherit nix; };
        zsh = pkgs.callPackage ./zsh.nix { };

        nixos-iso = nixos.callPackage ./nixos-iso.nix {
          inherit nixos;
          inherit (inputs.self.lib) mkNixOS;
          modules = [ ];
        };

      } // lib.optionalAttrs isDarwin {

        aquaskk-reload-config = pkgs.callPackage ./aquaskk-reload-config {
          inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
        };

        nix-darwin = pkgs.callPackage ./nix-darwin.nix {
          inherit nix;
          inherit (inputs) darwin;
        };

      } // pkgs.callPackages ./skk-jisyo.nix { };
    };
}
