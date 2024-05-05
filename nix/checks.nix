{ lib, inputs, ... }:

{
  perSystem =
    { self', system, ... }:
    {
      checks =
        let
          homeConfigurations' = self'.legacyPackages.homeConfigurations or { };
          homeConfigurations = lib.filterAttrs (name: home: home.pkgs.system == system) (
            inputs.self.homeConfigurations or { }
          );
          homeChecks = lib.mapAttrs' (
            name: home: lib.nameValuePair "home-manager-${name}" home.activationPackage
          ) (homeConfigurations' // homeConfigurations);

          darwinConfigurations = lib.filterAttrs (name: darwin: darwin.pkgs.system == system) (
            inputs.self.darwinConfigurations or { }
          );
          darwinChecks = lib.mapAttrs' (
            name: darwin: lib.nameValuePair "nix-darwin-${name}" darwin.config.system.build.toplevel
          ) darwinConfigurations;
        in
        homeChecks // darwinChecks;
    };
}
