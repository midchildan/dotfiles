# nix-darwin

## About

This directory contains configuration for [nix-darwin][nix-darwin].

This document focuses on aspects that are unique to this dotfiles. Detailed
usage instructions for nix-darwin itself can be found in the [official
docs][docs].

## Configuration

| Directory              | Contents                             |
| ---------------------- | ------------------------------------ |
| [`modules`](modules)   | Contains custom nix-darwin modules   |
| [`profiles`](profiles) | Contains profiles                    |
| [`machines`](machines) | Contains configuration for each host |

A profile basically refers to a nix-darwin module. The distinction is somewhat
arbitrary, but a module targeting a specific piece of software is placed in
`modules` while a module targeting a specific use case is placed in `profiles`.

The configuration for nix-darwin is chosen based on the hostname unless a
specific one is chosen via the command line. Configuration for each host are
defined in [`machines`](machines), so make sure to add hosts as necessary.

## How to add configuration for new hosts

Add them to [this file](machines/default.nix). Here's an example of how this
might look like for a host named `pod042`:

```nix
pod042 = mkDarwin {
  modules = [{
    dotfiles.profiles.apps.enable= true;
    system.stateVersion = 4;
  }];
};
```

`mkDarwin` is a wrapper for [`darwinSystem`][darwin-system] that bundles custom
nix-darwin modules in this dotfiles repository along with optional Home Manager
integration.

There's also an `importDarwin` function that allows you to split out the
configuration into a separate file. To use this, replace `mkDarwin` with the
below:

```nix
pod042 = importDarwin ./pod042.nix { };
```

Then move the configuration into `pod042.nix`:

```nix
{
  dotfiles.profiles.apps.enable = true;
  system.stateVersion = 4;
}
```

Finally, it's also possible to place host configuration in a separate repository
by creating a new Nix flake that takes this repository as input. See the
[description in the `templates` directory](../templates) for more details.

## Custom Options

This dotfiles introduces an additional option for nix-darwin as outlined below:

<dl>
  <dt>dotfiles.profiles.apps.enable</dt>
  <dd>
    Installs essential macOS applications. Since this relies on Homebrew Cask,
    Homebrew needs to be installed beforehand for this option to work.
  </dd>
</dl>

[nix-darwin]: https://github.com/LnL7/nix-darwin
[docs]: https://daiderd.com/nix-darwin/manual/index.html
[darwin-system]: https://github.com/LnL7/nix-darwin#flakes-experimental
