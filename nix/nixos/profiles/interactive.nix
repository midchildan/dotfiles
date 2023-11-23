{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles.profiles.interactive;
  hasConfigHW = config.dotfiles.profiles.hardware.enable;
in
{
  options.dotfiles.profiles.interactive = {
    enable = lib.mkEnableOption "configuration for interactive logins";
    username = lib.mkOption {
      type = lib.types.str;
      default = config.dotfiles.flakeOptions.user.name;
      description = "Username for interactive logins.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    users = {
      defaultUserShell = pkgs.zsh;

      users.root = {
        hashedPassword = "!";
        shell = pkgs.shadow; # package for nologin
      };

      users.${cfg.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
}
