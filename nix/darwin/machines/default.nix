{ inputs, ... }:

let
  inherit (inputs.self.lib) importDarwin pkgsFor;
in
{
  flake.darwinConfigurations = {
    # By default Nix-Darwin would look for a configuration whose name matches
    # its hostname.
    ci = importDarwin ./ci.nix { pkgs = pkgsFor "aarch64-darwin"; };
  };
}
