{
  perSystem =
    {
      lib,
      pkgs,
      config,
      self',
      ...
    }:
    {
      devShells = {
        default = pkgs.callPackage ./shell.nix {
          formatters = [ self'.formatter ] ++ (lib.attrValues config.treefmt.build.programs);
        };

        ansible = pkgs.callPackage ./ansible.nix { };

        setup = pkgs.callPackage ./setup.nix { inherit (self'.packages) neovim; };

        quic = pkgs.callPackage ./quic.nix { };
      };
    };
}
