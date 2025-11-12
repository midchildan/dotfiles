{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isLinux;
  isGenericLinux = (config.targets.genericLinux.enable or false);
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
        github-cli
        semgrep
        shellcheck
        tokei
        universal-ctags
        gitAndTools.git-absorb
        nodePackages.prettier
      ]
      ++ lib.optionals isLinux [ distrobox ]
      ++ lib.optionals isNixOS [ man-pages ];

    programs.direnv = {
      enable = lib.mkDefault true;
      nix-direnv.enable = lib.mkDefault true;
    };

    dotfiles.gitsign = {
      enable = lib.mkDefault true;
      enableCredentialCache = lib.mkDefault true;
      settings.connectorID = lib.mkDefault "https://github.com/login/oauth";
    };
  };
}
