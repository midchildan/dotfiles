{ inputs, config, ... }:

let
  inherit (inputs.self.lib) importHome;
  username = config.dotfiles.user.name;
in
{
  flake.homeConfigurations = rec {
    # Unless specified otherwise, Home Manager would look for an attribute whose
    # name matches "username@hostname" in order to build its configuration. If no
    # match is found, it falls back to the current username.
    ${username} = ci;

    ci = importHome ./ci.nix { system = "x86_64-linux"; };
  };
}
