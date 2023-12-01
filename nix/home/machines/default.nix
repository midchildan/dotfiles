{ inputs, config, ... }:

let
  inherit (inputs.self.lib) importHome pkgsFor;
  username = config.dotfiles.user.name;
in
{
  flake.homeConfigurations = rec {
    # Unless specified otherwise, Home Manager would look for an attribute whose
    # name matches "username@hostname" in order to build its configuration. If
    # no match is found, it falls back to the current username.
    "${username}@demo" = importHome ./ci.nix {
      pkgs = pkgsFor "x86_64-linux";
    };
  };

  perSystem = { pkgs, ... }: {
    # It's a bit non-standard, but putting a configuration under legacyPackages
    # will make it available for multiple architectures under the same name.
    legacyPackages.homeConfigurations =
      let
        ci = importHome ./ci.nix { inherit pkgs; };
      in
      {
        inherit ci;
        ${username} = ci;
      };
  };
}
