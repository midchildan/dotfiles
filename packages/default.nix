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

  inherit (pkgs) noto-fonts-cjk-serif;

  neovim = pkgs.callPackage ./neovim.nix { };
  siege = pkgs.callPackage ./siege.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6.nix {
    inherit sources;
  };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { nix = pkgs.nix_2_4; };
  zsh = pkgs.callPackage ./zsh.nix { };

} // optionalAttrs isDarwin {

  nix-darwin = pkgs.callPackage ./nix-darwin.nix {
    inherit (inputs) darwin;
    nix = pkgs.nix_2_4;
  };

}
