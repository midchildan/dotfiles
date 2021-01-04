{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles.emacs;
  createConfPackage = epkgs:
    epkgs.trivialBuild {
      pname = "default";
      version = "1";
      src = pkgs.writeText "default.el" cfg.extraConfig;
    };
in {
  options.dotfiles.emacs = {
    enable = mkOption {
      default = config.programs.emacs.enable;
      type = types.bool;
      description = ''
        Whether to enable extra configuration for Emacs installed by
        <option>programs.emacs</option>.
      '';
    };

    extraConfig = mkOption {
      default = "";
      type = types.lines;
      description = ''
        Extra elisp code that should be run when initializing Emacs.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.emacs.extraPackages = epkgs: [ (createConfPackage epkgs) ];
  };
}
