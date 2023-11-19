{ pkgs ? import <nixpkgs> { }
, nixos ? import <nixos> { }
, inputs ? { }
}:

let
  inherit (pkgs.lib) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
  nix = pkgs.nixVersions.${inputs.self.lib.config.nix.package};
  sources = pkgs.callPackage ./_sources/generated.nix { };
in
rec {

  mmdbctl = pkgs.callPackage ./mmdbctl.nix { };
  neovim = pkgs.callPackage ./neovim.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli/default.nix {
    inherit sources;
  };

  coc-ansible = pkgs.callPackage ./coc-ansible.nix {
    inherit (pkgs.vimUtils) buildVimPlugin;
  };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { inherit nix; };
  zsh = pkgs.callPackage ./zsh.nix { };

  nixos-iso = nixos.callPackage ./nixos-iso.nix {
    inherit (inputs.self.lib) mkNixOS;
    modules = [ ];
  };

} // optionalAttrs isDarwin {

  aquaskk-reload-config = pkgs.callPackage ./aquaskk-reload-config {
    inherit (pkgs.darwin.apple_sdk.frameworks) Foundation;
  };

  nix-darwin = pkgs.callPackage ./nix-darwin.nix {
    inherit nix;
    inherit (inputs) darwin;
  };

} // pkgs.callPackages ./skk-jisyo.nix { }
