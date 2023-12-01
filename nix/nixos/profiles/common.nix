{ lib, config, options, pkgs, ... }:

let
  inherit (lib) mkDefault;
  inherit (config.dotfiles) flakeOptions;
  nixAttrName = flakeOptions.nix.package;
in
{
  config = {
    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    console.keyMap = mkDefault "us";

    time.timeZone = mkDefault "Asia/Tokyo";

    nix.package = mkDefault pkgs.nixVersions.${nixAttrName};
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # FIXME: remove after upgrading to NixOS 23.11
    # https://github.com/NixOS/nixpkgs/pull/257458
    nixpkgs.config =
      if options.nixpkgs.pkgs.isDefined
      then pkgs.config
      else flakeOptions.nixpkgs.args.config;

    system.stateVersion = lib.mkDefault flakeOptions.nixos.stateVersion;
  };
}
