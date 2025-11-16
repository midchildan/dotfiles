{
  config,
  lib,
  ...
}:

{
  options.dotfiles.profiles.development.enable = lib.mkEnableOption "development environments";

  config = lib.mkIf config.dotfiles.profiles.development.enable {
    nix.linux-builder.enable = lib.mkDefault true;
  };
}
