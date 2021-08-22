{ inputs }:

let
  inherit (inputs.self.lib) config importHome;
in
{
  # Unless specified otherwise, Home Manager would look for an attribute whose
  # name matches the current hostname in order to build its configuration. If no
  # match is found, it falls back to the current username.
  ${config.user.name} = importHome ./generic-host.nix { };
}
