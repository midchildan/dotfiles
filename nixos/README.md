# NixOS

## About

This directory contains configuration for the [NixOS][nixos] system environment.

This document focuses on aspects that are unique to this dotfiles. Detailed
usage instructions for NixOS itself can be found in the [official
docs][nixos-docs].

## Configuration

| Directory              | Contents                             |
| ---------------------- | ------------------------------------ |
| [`profiles`](profiles) | Contains profiles                    |
| [`machines`](machines) | Contains configuration for each host |

A profile refers to a NixOS module targeting a specific use case.

The configuration for NixOS is chosen based on the hostname unless a specific
one is chosen via the command line. Configuration for each host are defined in
[`machines`](machines), so make sure to add hosts as necessary.

## How to add configuration for new hosts

Add them to [this file](machines/default.nix). Here's an example of how this
might look like for a host named `pod042`:

```nix
pod042 = mkNixOS {
  modules = [{
    dotfiles.profiles = {
      laptop.enable = true;
      interactive.username = "yorha2b";
    };

    users.mutableUsers = false;

    # NOTE: Maybe use https://github.com/ryantm/agenix
    users.users.yorha2b.passwordFile = "/run/secrets/hashed-login-password";

    system.stateVersion = "21.11";
  }];
};
```

`mkNixOS` is a wrapper for [`nixosSystem`][nixos-system] that bundles custom
NixOS modules in this dotfiles repository along with optional Home Manager
integration.

There's also an `importNixOS` function that allows you to split out the
configuration into a separate file. To use this, replace `mkNixOS` with the
below:

```nix
pod042 = importNixOS ./pod042.nix { };
```

Then move the configuration into `pod042.nix`:

```nix
{
  dotfiles.profiles = {
    laptop.enable = true;
    interactive.username = "yorha2b";
  };

  users.mutableUsers = false;

  # NOTE: Maybe use https://github.com/ryantm/agenix
  users.users.yorha2b.passwordFile = "/run/secrets/hashed-login-password";

  system.stateVersion = "21.11";
}
```

Finally, it's also possible to place host configuration in a separate repository
by creating a new Nix flake that takes this repository as input. See the
[description in the `templates` directory](../templates) for more details.

## Custom Options

This dotfiles introduces a few additional options for NixOS. Here's some of the
interesting ones:

<dl>
  <dt>dotfiles.profiles.desktop.enable</dt>
  <dd>
    Configures a desktop environment.
  </dd>
  <dt>dotfiles.profiles.desktop.desktop</dt>
  <dd>
    Choose a desktop environment to use. Currently available options are Gnome
    and KDE.
  </dd>
  <dt>dotfiles.profiles.hardware.enable</dt>
  <dd>
    Configuration for bare metal.
  </dd>
  <dt>dotfiles.profiles.hardware.hidpi.enable</dt>
  <dd>
    Configuration for HiDPI displays.
  </dd>
  <dt>dotfiles.profiles.laptop.enable</dt>
  <dd>
    Configuration for laptops.
  </dd>
  <dt>dotfiles.profiles.network.enable</dt>
  <dd>
    Network related configuration.
  </dd>
</dl>

[nixos]: https://nixos.org
[nixos-docs]: https://nixos.org/learn
[nixos-system]: https://nixos.wiki/wiki/Flakes
