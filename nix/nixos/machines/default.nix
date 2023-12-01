{ inputs, ... }:

let
  inherit (inputs.self.lib) importNixOS nixosFor;
in
{
  flake.nixosConfigurations = {
    # By default NixOS would look for a configuration whose name matches its
    # hostname.
    ci = importNixOS ./ci.nix { pkgs = nixosFor "x86_64-linux"; };
  };
}
