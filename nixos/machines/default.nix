{ inputs }:

let
  inherit (inputs.self.lib) importNixOS;
in
{
  # By default NixOS would look for a configuration whose name matches its
  # hostname.
  ci = importNixOS ./ci.nix { };
}
