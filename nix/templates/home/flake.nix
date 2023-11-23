{
  description = "Home Manager configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    dotfiles.url = "github:midchildan/dotfiles";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
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

      flake.homeManagerConfigurations.my-desktop = self.lib.mkHome {
        system = "x86_64-linux";
        configuration = {
          # Options are defined in:
          # https://github.com/midchildan/dotfiles/blob/nix/home
          dotfiles.profiles.enableAll = true;
          home.stateVersion = "23.05";
        };
      };
    };
}
