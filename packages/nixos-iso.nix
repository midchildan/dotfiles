{ stdenv
, mkNixOS
, modules ? [ ]
}:

let
  upstreamConfig = { modulesPath, ... }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ];
  };

  customConfig = { lib, ... }: {
    isoImage.edition = lib.mkOverride 10 "unofficial";
    dotfiles.profiles.installer.enable = true;
  };

  installer = mkNixOS {
    inherit (stdenv.hostPlatform) system;
    modules = [ upstreamConfig customConfig ] ++ modules;
  };

  inherit (installer.config.system.build) isoImage;
in
isoImage.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Custom installer ISO image for NixOS.";
  };
})
