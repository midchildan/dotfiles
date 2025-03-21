{
  config,
  lib,
  pkgs,
  dotfiles,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux system;
  isGenericLinux = (config.targets.genericLinux.enable or false);
  isNixOS = isLinux && !isGenericLinux;
  cfg = config.dotfiles.profiles;
  myPkgs = dotfiles.packages.${system};
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

    dotfiles.gnupg = {
      enable = lib.mkDefault true;
      enablePackage = lib.mkDefault (!isNixOS); # use the NixOS module instead
    };
  };
}
