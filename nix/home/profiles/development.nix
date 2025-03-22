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
        github-cli
        semgrep
        shellcheck
        tokei
        universal-ctags
      ]
      ++ lib.optionals isLinux [ distrobox ]
      ++ lib.optionals isNixOS [ man-pages ];
  };
}
