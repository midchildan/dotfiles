{
  perSystem =
    { pkgs, self', ... }:
    {
      devShells = {
        default = pkgs.callPackage ./shell.nix { inherit (self') formatter; };

        ansible = pkgs.callPackage ./ansible.nix { };

        setup = pkgs.callPackage ./setup.nix { inherit (self'.packages) neovim; };

        quic = pkgs.callPackage ./quic.nix { };
      };
    };
}
