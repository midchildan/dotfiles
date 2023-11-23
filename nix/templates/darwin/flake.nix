{
  description = "Darwin configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    dotfiles.url = "github:midchildan/dotfiles";
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

      flake.darwinConfigurations.my-macbook = self.lib.mkDarwin {
        system = "aarch64-darwin";
        modules = [{
          # Options are defined in:
          # https://github.com/midchildan/dotfiles/blob/nix/darwin
          dotfiles.profiles.apps.enable = true;
          system.stateVersion = 4;

          home-manager.users.${config.dotfiles.user.name} = {
            # Options are defined in:
            # https://github.com/midchildan/dotfiles/blob/nix/home
            dotfiles.profiles.enableAll = true;
            home.stateVersion = "23.05";
          };
        }];
      };
    });
}
