{ inputs }:

let
  inherit (inputs.self.lib) importNixOS;
in
{
  # By default NixOS would look for a configuration whose name matches its
  # hostname.
  generic = importNixOS ./generic-host.nix { };
}
