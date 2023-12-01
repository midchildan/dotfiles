{
  description = "Home Manager configuration";

  inputs = {
    dotfiles.url = "github:midchildan/dotfiles";
    flake-parts.follows = "dotfiles/flake-parts";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, pkgsFor, ... }: {
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

      flake.homeManagerConfigurations = {
        "${config.dotfiles.user}@my-desktop" = self.lib.mkHome {
          pkgs = pkgsFor "x86_64-linux";
          modules = [{
            # Options are defined in:
            # https://github.com/midchildan/dotfiles/blob/nix/home
            dotfiles.profiles.enableAll = true;
            home.stateVersion = "23.05";
          }];
        };
      };
    });
}
