{
  description = "NixOS configuration";

  inputs = {
    dotfiles.url = "github:midchildan/dotfiles";
    flake-parts.follows = "dotfiles/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, ... }: {
      imports = [
        inputs.dotfiles.flakeModules.default
      ];

      dotfiles.user = {
        # See list of options in:
        # https://github.com/midchildan/dotfiles/blob/main/nix/config.nix
        name = "midchildan";
        email = "foo@bar.example";
        pgpKey = "";
      };

      flake.nixosConfigurations.my-desktop = self.lib.mkNixOS {
        pkgs = self.lib.nixosFor "x86_64-linux";
        modules = [{
          # Options are defined in:
          # https://github.com/midchildan/dotfiles/blob/nix/nixos
          dotfiles.profiles = {
            hardware.enable = true;
            interactive.enable = true;
            network.enable = true;
            desktop.enable = true;
          };
          system.stateVersion = "23.11";
        }];
      };
    });
}
