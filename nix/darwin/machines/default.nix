{ inputs, pkgsFor, ... }:

let
  inherit (inputs.self.lib) importDarwin;
in
{
  flake.darwinConfigurations = {
    # By default Nix-Darwin would look for a configuration whose name matches
    # its hostname.
    ci = importDarwin ./ci.nix { pkgs = pkgsFor "aarch64-darwin"; };
    ci-amd64 = importDarwin ./ci.nix { pkgs = pkgsFor "x86_64-darwin"; };
  };
}
