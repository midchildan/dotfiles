{
  lib,
  stdenv,
  emptyFile,
  mkNixOS,
  nixos,
  modules ? [ ],
}:

let
  upstreamConfig =
    { modulesPath, ... }:
    {
      imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];
    };

  customConfig =
    { lib, ... }:
    {
      isoImage.edition = lib.mkOverride 10 "unofficial";
      dotfiles.profiles.installer.enable = true;
    };

  installer = mkNixOS {
    pkgs = nixos;
    modules = [
      upstreamConfig
      customConfig
    ] ++ modules;
  };

  # The original isoImage may refuse to evaluate meta.platforms for incompatible systems because it
  # contains an assertion which depends on another Linux only derivation.
  isoImage = if stdenv.isLinux then installer.config.system.build.isoImage else emptyFile;
in
isoImage.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Custom installer ISO image for NixOS.";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ midchildan ];
  };
})
