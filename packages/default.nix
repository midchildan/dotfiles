{ pkgs ? import <nixpkgs> { }
, nixos ? import <nixos> { }
, inputs ? { }
}:

let
  inherit (pkgs.lib) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
rec {

  nixpath = pkgs.callPackage ./nixpath.nix { };
  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6 { };
  neovim = pkgs.callPackage ./neovim.nix { };
  nghttp3 = pkgs.callPackage ./nghttp3.nix { };
  ngtcp2 = pkgs.callPackage ./ngtcp2.nix { inherit nghttp3 quictls; };
  noto-serif-cjk = pkgs.callPackage ./noto-serif-cjk.nix { };
  siege = pkgs.callPackage ./siege.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };
  quictls = pkgs.callPackage ./quictls.nix { };
  curl-h3 = pkgs.callPackage ./curl-h3.nix {
    inherit nghttp3 ngtcp2 quictls;
    inherit (pkgs.darwin.apple_sdk.frameworks) SystemConfiguration;
  };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  nixos-rebuild = nixos.callPackage ./nixos-rebuild.nix { };
  zsh = pkgs.callPackage ./zsh.nix { };

} // optionalAttrs isDarwin {

  nix-darwin = pkgs.callPackage ./nix-darwin.nix { inherit (inputs) darwin; };
  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };

}
