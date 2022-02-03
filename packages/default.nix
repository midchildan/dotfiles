{ pkgs ? import <nixpkgs> { }
, nixos ? import <nixos> { }
, inputs ? { }
}:

let
  inherit (pkgs.lib) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
rec {

  inherit (pkgs) noto-fonts-cjk-serif;

  nixpath = pkgs.callPackage ./nixpath.nix { };
  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6 { };
  neovim = pkgs.callPackage ./neovim.nix { };
  siege = pkgs.callPackage ./siege.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { nix = pkgs.nix_2_4; };
  zsh = pkgs.callPackage ./zsh.nix { };

} // optionalAttrs isDarwin {

  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };
  nix-darwin = pkgs.callPackage ./nix-darwin.nix {
    inherit (inputs) darwin;
    nix = pkgs.nix_2_4;
  };

}
