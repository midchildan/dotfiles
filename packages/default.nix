{ pkgs ? import <nixpkgs> { }
, nixos ? import <nixos> { }
, inputs ? { }
}:

let
  inherit (pkgs.lib) optionalAttrs;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{

  nixpath = pkgs.callPackage ./nixpath.nix { };
  cloudfoundry-cli-6 = pkgs.callPackage ./cloudfoundry-cli-6 { };
  neovim = pkgs.callPackage ./neovim.nix { };
  terminfo-collection = pkgs.callPackage ./terminfo-collection.nix { };

} // optionalAttrs isLinux {

  bpftrace = nixos.callPackage ./bpftrace.nix { };
  nixos-rebuild = pkgs.callPackage ./nixos-rebuild.nix { };
  zsh = pkgs.callPackage ./zsh.nix { };

} // optionalAttrs isDarwin {

  nix-darwin = pkgs.callPackage ./nix-darwin.nix { inherit (inputs) darwin; };
  pinentry_mac = pkgs.callPackage ./pinentry-mac.nix { };

}
