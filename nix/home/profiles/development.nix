{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  inherit (config.dotfiles) flakeOptions;
  isGenericLinux = config.targets.genericLinux.enable or false;
  isNixOS = isLinux && !isGenericLinux;
  cfg = config.dotfiles.profiles;
in
{
  options.dotfiles.profiles.development.enable = lib.mkEnableOption "development packages";

  config = lib.mkIf cfg.development.enable {
    home.packages =
      with pkgs;
      [
        devenv
        git-absorb
        github-cli
        semgrep
        shellcheck
        tokei
        universal-ctags
        nodePackages.prettier
      ]
      ++ lib.optionals isLinux [ distrobox ]
      ++ lib.optionals isNixOS [ man-pages ]
      ++ lib.optionals cfg.extras.enable [ nixos-shell ];

    programs.direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = lib.mkDefault true;
    };

    programs.jujutsu = {
      enable = lib.mkDefault true;
      settings = {
        user = {
          name = flakeOptions.user.fullName;
          email = flakeOptions.user.email;
        };
      };
    };

    dotfiles.gitsign = {
      enable = lib.mkDefault true;
      enableCredentialCache = lib.mkDefault true;
      settings.connectorID = lib.mkDefault "https://github.com/login/oauth";
    };
  };
}
