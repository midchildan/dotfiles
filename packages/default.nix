{ pkgs ? import <nixpkgs> { }
, nixos ? import <nixos> { }
, inputs ? { }
}:

let
  inherit (pkgs.lib) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
  sources = pkgs.callPackage ./_sources/generated.nix { };
in
rec {

  neovim = pkgs.callPackage ./neovim.nix { };
  siege = pkgs.callPackage ./siege.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6.nix {
    inherit sources;
  };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  zsh = pkgs.callPackage ./zsh.nix { };

  nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix {
    nix = pkgs.nixVersions.nix_2_8;
  };

} // optionalAttrs isDarwin {

  nix-darwin = pkgs.callPackage ./nix-darwin.nix {
    inherit (inputs) darwin;
    nix = pkgs.nixVersions.nix_2_8;
  };

}
