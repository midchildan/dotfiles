{ config, modulesPath, ... }:

let
  inherit (config.dotfiles.profiles.interactive) username;
in
{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  dotfiles.profiles = {
    interactive.enable = true;
    network.enable = true;
    desktop.enable = true;
  };

  users.users.${username}.password = "";

  system.stateVersion = "23.11";
}
