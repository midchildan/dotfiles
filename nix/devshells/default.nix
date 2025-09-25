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
        default = pkgs.callPackage ./shell.nix { inherit config; };

        ansible = pkgs.callPackage ./ansible.nix { };

        setup = pkgs.callPackage ./setup.nix { };
      };
    };
}
