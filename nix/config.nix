{ inputs }@localFlake:
{ lib, config, ... }@flake:

let
  cfg = flake.config.dotfiles;
  nixosRelease = localFlake.inputs.nixos.lib.trivial.release;
in
{
  options.dotfiles = {
    user = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "The default username to use throughout this flake.";
        default = "midchildan";
      };

      fullName = lib.mkOption {
        type = lib.types.str;
        description = "The default full name to use throughout this flake.";
        default = cfg.user.name;
      };

      email = lib.mkOption {
        type = lib.types.str;
        description = "The default email to use throughout this flake.";
        default = "git@${cfg.user.name}.org";
      };

      pgpKey = lib.mkOption {
        type = lib.types.str;
        description = "The default PGP key to use throughout this flake.";
        default = "FEF0AE2D544934825F0640AA186A1EDAC5C63F83";
      };
    };

    nix.package = lib.mkOption {
      type = lib.types.str;
      description = "The Nix package to use, specified by attribute name.";
      default = "nix_2_13";
    };

    home = {
      modules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        default = [ ];
        description = ''
          Default list of modules to include when generating Home Manager
          configuration with `lib.mkHome` and `lib.importHome`.
        '';
      };

      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = nixosRelease;
        description = ''
          The default `stateVersion` to use for Home Manager.

          More info is available at
          <https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion>.

          ::: {.warning}
          Make sure to understand what the following does. It's strongly
          recommended to override this option this per host.
          :::
        '';
      };
    };

    nixos = {
      modules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        default = [ ];
        description = ''
          Default list of modules to include when generating NixOS configuration
          with `lib.mkNixOS` and `lib.importNixOS`.
        '';
      };

      stateVersion = lib.mkOption {
        type = lib.types.str;
        default = nixosRelease;
        description = ''
          The default `stateVersion` to use for NixOS.

          More info is available at
          <https://search.nixos.org/options?show=system.stateVersion>.

          ::: {.warning}
          Make sure to understand what the following does. It's strongly
          recommended to override this option this per host.
          :::
        '';
      };
    };

    darwin = {
      modules = lib.mkOption {
        type = with lib.types; listOf deferredModule;
        default = [ ];
        description = ''
          Default list of modules to include when generating nix-darwin
          configuration with `lib.mkDarwin` and `lib.importDarwin`.
        '';
      };

      stateVersion = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4;
        description = ''
          The default `stateVersion` to use for nix-darwin.

          More info is available at
          <https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion>.

          ::: {.warning}
          Make sure to understand what the following does. It's strongly
          recommended to override this option this per host.
          :::
        '';
      };
    };
  };
}
