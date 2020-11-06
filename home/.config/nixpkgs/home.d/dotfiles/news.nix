{ ... }:

{
  config.news.entries = [
    {
      time = "2020-11-06T05:23:50+00:00";
      message = ''
        A new module is available: 'programs.dotfiles'

        This module consists of three smaller modules that can be enabled on an
        individual basis. The options for enabling them are:

        - minimal.enable

          This would install the bare minimum amount of packages necessary to
          make the dotfiles useful. Enabled by default.

        - essential.enable

          This would install essential utilities for servers and desktops alike.
          It mainly targets development machines. Disabled by default.

        - desktop.enable

          This would install essential packages for the NixOS desktop. It's
          intended for personal machines. Disabled by default.

        Note, this is part of dotfiles and not a standard home-manager module.
      '';
    }
  ];
}
