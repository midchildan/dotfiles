{
  flake-parts-lib,
  lib,
  config,
  self,
  ...
}:

let
  inherit (flake-parts-lib) importApply;
  nixAttrName = config.dotfiles.nix.package;

  flakeModules.updater = {
    imports = [ (importApply ./flake-module.nix { inherit config; }) ];
  };
in
{
  imports = [ flakeModules.updater ];

  flake = {
    inherit flakeModules;
  };

  perSystem =
    {
      pkgs,
      inputs',
      self',
      ...
    }:
    {
      apps =
        {
          home.program = "${inputs'.home.packages.default}/bin/home-manager";
          ansible.program = "${pkgs.callPackage ./ansible.nix { }}";
          neovim.program =
            let
              homeConf = self.lib.mkHome {
                inherit pkgs;
                modules = [
                  {
                    dotfiles.profiles = {
                      minimal.enable = false;
                      neovim.enable = true;
                    };
                    home.stateVersion = "24.05";
                  }
                ];
              };
              nvim = "${homeConf.activationPackage}/home-path/bin/nvim";
              configDir = "${homeConf.activationPackage}/home-files/.config";
            in
            pkgs.writers.writeBashBin "nvim" ''
              unset NVIM_APPNAME MYVIMRC
              export XDG_CONFIG_HOME=${configDir}
              ${nvim} "$@"
            '';
        }
        // lib.optionalAttrs pkgs.stdenv.isLinux {
          os.program = "${self'.packages.nixos-rebuild}/bin/nixos-rebuild";
        }
        // lib.optionalAttrs pkgs.stdenv.isDarwin {
          os.program = "${inputs'.darwin.packages.default}/bin/darwin-rebuild";
        };
    };
}
