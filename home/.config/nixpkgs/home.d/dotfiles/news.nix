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
    {
      time = "2020-12-12T16:18:03+00:00";
      message = ''
        Remove option 'dotfiles.fixes.localeArchive.enable

        The configuration that was introduced by this option would be applied
        without the need of explicit configuration.
      '';
    }
    {
      time = "2020-12-26T14:15:32+00:00";
      message = ''
        A new module is available: 'dotfiles.profiles.extras'
      '';
    }
    {
      time = "2021-01-04T13:56:45+00:00";
      message = ''
        A new module is available: 'dotfiles.emacs'

        This module can be used to add custom initialization code to Emacs
        installed through the 'programs.emacs' module.
      '';
    }
    {
      time = "2021-01-07T05:35:08+00:00";
      message = ''
        A new module is available: 'dotfiles.fonts'

        This module makes installed fonts available on non-NixOS platforms. On
        macOS, this may overwrite existing user fonts installed in
        ~/Library/Fonts. This shouldn't be a concern in most cases because even
        if it does overwrite existing fonts, it's just going to replace it with
        the same or newer versions. But it's something to be aware of.
      '';
    }
    {
      time = "2021-01-07T05:36:14+00:00";
      message = ''
        A new module is available: 'dotfiles.profiles.fonts'

        This installs a collection of recommended fonts for use with the
        dotfiles.
      '';
    }
    {
      time = "2021-01-20T19:15:56+00:00";
      message = ''
        A new module is available: 'dotfiles.macos'

        This module can be used to configure macOS user settings.
      '';
    }
    {
      time = "2021-01-21T13:38:02+00:00";
      message = ''
        A new module is available: 'dotfiles.launchd'

        This module can be used to create macOS user Launch Agents. Note,
        however, that automatically starting or stopping Launch Agents upon
        switching Home Manager generations isn't supported yet.
      '';
    }
    {
      time = "2021-01-21T13:39:49+00:00";
      message = ''
        A new module is available: 'dotfiles.syncthing'

        This is a Syncthing module that works on macOS. On Linux, it just wraps
        around 'services.syncthing'.
      '';
    }
  ];
}
