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
    {
      time = "2020-11-06T14:44:02+00:00";
      message = ''
        A new module is available: 'programs.dotfiles.debugTools'

        If you enable this module on a non-NixOS distribution, make sure to
        enable the 'config.targets.genericLinux' option in your Home Manager
        configuration or installation would fail.
      '';
    }
    {
      time = "2020-11-11T14:29:48+00:00";
      message = ''
        A new module is available: 'programs.dotfiles.development'
      '';
    }
    {
      time = "2020-11-11T14:45:47+00:00";
      message = ''
        A new option is available: 'programs.dotfiles.enableAll'

        This enables all modules available under programs.dotfiles.
      '';
    }
  ];
}
