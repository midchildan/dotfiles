# Home Manager

## Overview

[Home Manager][home] is used to manage per-user packages and daemons. It's also
used to generate configuration files for some software, but this dotfiles mostly
stick to [hand-written configuration files][files] and relies on the
Nix-agnostic [setup.sh][setup] for deployment where it makes sense.

This document focuses on aspects of Home Manager configuration that are unique
to this dotfiles. Detailed usage instructions for Home Manager itself can be
found in the [official manual][home-docs].

## Relationship with NixOS / nix-darwin

Home Manager is responsible for per-user settings while NixOS and nix-darwin
manages system-wide settings. This dotfiles uses both.

When choosing where to place a given configuration, prefer Home Manager over
system-wide configuration unless there's a reason not to. This would provide the
following benefits:

- Home Manager is usable on any Linux distro with Nix installed
- Home Manager can share configuration between Linux and macOS
- You can enjoy up to date packages with Home Manager while using stable
  packages for NixOS / nix-darwin

## Best Practices

While Home Manager is a convenient method for package management, it's not
exactly good practice to install anything and everything with it. For software
tied to a specific project, it's recommended to keep the installation local to
that project instead of installing it globally. Nix handles this pretty well
with [nix-shell][nix-shell] and [direnv][direnv]. [Direnv's wiki][direnv-wiki]
contains a detailed explanation about this setup. [nix-direnv][nix-direnv],
which further integrates the two, is also included as part of the Home Manager
configuration for this dotfiles.

## Layout

| Directory              | Contents                             |
| ---------------------- | ------------------------------------ |
| [`modules`](modules)   | Contains custom Home Manager modules |
| [`profiles`](profiles) | Contains profiles                    |
| [`machines`](machines) | Contains configuration for each host |

A profile basically refers to a Home Manager module. The distinction is somewhat
arbitrary, but a module targeting a specific piece of software is placed in
`modules` while a module targeting a specific use case is placed in `profiles`.

Multiple Home Manager configurations can be defined, and Home Manager will use
the one with the matching hostname unless specified otherwise via command line
arguments. Configuration for each host are defined in [`machines`](machines), so
make sure to add new hosts in there as necessary. If no hostname matches are
found, Home Manager would attempt to find a match based on the username instead.

## How to add configuration for new hosts

Add them to [this file](machines/default.nix). Here's an example of how this
might look like for a host named `pod042`:

```nix
pod042 = mkHome {
  configuration = {
    dotfiles.profiles.enableAll = true;
  };
  stateVersion = "21.11";
};
```

`mkHome` is a wrapper for [`homeManagerConfiguration`][home-conf] that bundles
custom Home Manager modules in this dotfiles repository.

There's also an `importHome` function that allows you to split out the
configuration into a separate file. To use this, replace `mkHome` with the
below:

```nix
pod042 = importHome ./pod042.nix { stateVersion = "21.11"; };
```

Then move the configuration into `pod042.nix`:

```nix
{
  dotfiles.profiles.enableAll = true;
}
```

Finally, it's also possible to place host configuration in a separate repository
by creating a new Nix flake that takes this repository as input. See the
[description in the `templates` directory](../templates) for more details.

## Custom Options

This dotfiles introduces a few additional options for Home Manager. Here's some
of the interesting ones:

<dl>
  <dt>dotfiles.profiles.minimal.enable</dt>
  <dd>
    Installs the bare minimum amount of packages needed for the dotfiles to
    function. Enabled by default.
  </dd>
  <dt>dotfiles.profiles.essential.enable</dt>
  <dd>
    Installs essential packages for servers and desktops alike. Disabled by
    default.
  </dd>
  <dt>dotfiles.profiles.extras.enable</dt>
  <dd>
    Installs nice to have packages. Disabled by default.
  </dd>
  <dt>dotfiles.profiles.development.enable</dt>
  <dd>
    Installs development packages. Disabled by default.
  </dd>
  <dt>dotfiles.profiles.debugTools.enable</dt>
  <dd>
    Installs debugging tools. Disabled by default.
  </dd>
  <dt>dotfiles.profiles.fonts.enable</dt>
  <dd>
    Installs recommended fonts. Disabled by default.
  </dd>
  <dt>dotfiles.profiles.desktop.enable</dt>
  <dd>
    Installs essential packages for desktop environemnts. It can be enabled for
    both Linux and macOS. Disabled by default.
  </dd>
  <dt>dotfiles.profiles.enableAll</dt>
  <dd>
    Enables all of the above. Disabled by default.
  </dd>
</dl>

[files]: ../../files
[setup]: ../../setup.sh
[home]: https://github.com/nix-community/home-manager
[home-conf]: https://github.com/nix-community/home-manager/blob/master/flake.nix
[home-docs]: https://nix-community.github.io/home-manager/
[nix-shell]: https://nixos.wiki/wiki/Development_environment_with_nix-shell
[direnv]: https://direnv.net
[direnv-wiki]: https://github.com/direnv/direnv/wiki/Nix
[nix-direnv]: https://github.com/nix-community/nix-direnv
