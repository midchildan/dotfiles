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
    {
      time = "2020-12-01T01:11:00+00:00";
      message = ''
        Rename option 'programs.dotfiles' -> 'profiles'

        Make sure to adjust your Home Manager settings in
        ~/.config/nixpkgs/home.d/ accordingly.
      '';
    }
    {
      time = "2020-12-02T18:36:47+00:00";
      message = ''
        Rename option 'profiles' -> 'dotfiles.profiles'

        Make sure to adjust your Home Manager settings in
        ~/.config/nixpkgs/home.d/ accordingly.
      '';
    }
    {
      time = "2020-12-02T19:42:28+00:00";
      message = ''
        A new module is available: 'dotfiles.pinentry-mac'

        This installs pinentry-mac to /usr/local/bin. Only available on macOS.
      '';
    }
    {
      time = "2020-12-03T16:49:51+00:00";
      message = ''
        A new module is available: 'dotfiles.manpages'

        This module installs manual pages without hiding the operating system's
        existing manual pages. This module was written because the manual pages
        for XCode Command Line Tools on macOS were not showing up with the
        default Home Manager configuration. A similar issue was reported at
        https://github.com/nix-community/home-manager/issues/432
      '';
    }
    {
      time = "2020-12-10T16:34:37+00:00";
      message = ''
        A new option is available: 'dotfiles.fixes.localeArchive.enable'

        When enabled, this prevents broken locale support when Home Manager
        packages require a locale archive format that is incompatible with what
        the host system provides.

        See also https://github.com/NixOS/nixpkgs/issues/38991
      '';
    }
  ];
}
