{ inputs, ... }:

let
  inherit (inputs.self.lib) importDarwin;
in
{
  flake.darwinConfigurations = {
    # By default Nix-Darwin would look for a configuration whose name matches
    # its hostname.
    ci = importDarwin ./ci.nix { system = "aarch64-darwin"; };
    ci-amd64 = importDarwin ./ci.nix { system = "x86_64-darwin"; };
  };
}
