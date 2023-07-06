{ lib, pkgs, dotfiles, ... }:

let
  nix = dotfiles.lib.config.nix.package;
in
{
  # Setup Nix and the Nix daemon. After nix-darwin has been activated, it should
  # be safe to remove the copy of Nix from the default profile.
  #
  # $ sudo -H nix-channel --remove nixpkgs
  # $ sudo -H nix-env -e '*'
  nix.package = lib.mkDefault pkgs.nixVersions.${nix};
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = lib.mkDefault true;
}
