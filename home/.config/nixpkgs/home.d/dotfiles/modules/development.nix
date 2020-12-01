{ config, lib, pkgs, ... }:

with lib;

let inherit (pkgs.stdenv.hostPlatform) isDarwin;
in {
  options.profiles.development.enable = mkEnableOption "Development packages";

  config = mkIf config.profiles.development.enable {
    home.packages = with pkgs;
      [ clang-tools github-cli gopls tokei universal-ctags ]
      ++ optionals isDarwin [ gnupg pinentry_mac ];
  };
}
