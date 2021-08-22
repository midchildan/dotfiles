{ inputs }:

let
  inherit (inputs.self.lib) importDarwin;
in
{
  # By default Nix-Darwin would look for a configuration whose name matches its
  # hostname.
  generic = importDarwin ./generic-host.nix { };
}
