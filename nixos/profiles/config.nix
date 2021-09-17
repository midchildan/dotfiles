{ lib, pkgs, dotfiles, ... }:

let
  inherit (lib) mkDefault;
in
{
  config = {
    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    console.keyMap = mkDefault "us";

    time.timeZone = mkDefault "Asia/Tokyo";

    nix.package = mkDefault pkgs.nixUnstable;
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';
    nixpkgs.config.allowUnfree = true;

    system.stateVersion = dotfiles.lib.config.os.stateVersion;
  };
}
