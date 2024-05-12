{
  lib,
  inputs,
  config,
  ...
}:

{
  perSystem =
    { pkgs, nixos, ... }:
    let
      inherit (pkgs.stdenv) isDarwin isLinux;
      nix = pkgs.nixVersions.${config.dotfiles.nix.package};
    in
    {
      packages =
        rec {

          mmdbctl = pkgs.callPackage ./mmdbctl.nix { };
          neovim = pkgs.callPackage ./neovim.nix { };
          terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

          coc-ansible = pkgs.callPackage ./coc-ansible.nix { inherit (pkgs.vimUtils) buildVimPlugin; };
        }
        // lib.optionalAttrs isLinux {

          nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { inherit nix; };
          zsh = pkgs.callPackage ./zsh.nix { };

          nixos-iso = nixos.callPackage ./nixos-iso.nix {
            inherit nixos;
            inherit (inputs.self.lib) mkNixOS;
            modules = [ ];
          };
        }
        // lib.optionalAttrs isDarwin {

          aquaskk-reload-config = pkgs.callPackage ./aquaskk-reload-config { };
        }
        // pkgs.callPackages ./skk-jisyo.nix { };
    };
}
