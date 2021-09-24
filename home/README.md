# User Environment

## About

This directory contains configuration files required to setup the user
environment. It consists of two parts, static dotfiles and Home Manager
configuration.

## Static Dotfiles

### Overview

These are set of configuration files in the [`files`](files) directory intended
to be installed under the home directory. With a few exceptions, most of these
files are deployed using a custom setup script, [`setup.sh`](../setup.sh).

The setup script deploys the dotfiles by symlinking them into the home
directory. These are deliberately managed outside of Nix for a few reasons.

The first reason is portability. Since the setup script won't rely on Nix, it
could be installed on systems without Nix. Most parts of the dotfiles should
just work fine without Nix.

The second reason is convenience. Files deployed using Home Manager are
symlinked from the Nix store, which is an immutable directory typically located
at `/nix/store`. This can turn out to be a bit an inconvenience sometimes. For
example, when testing quick changes, you can't just edit the files directly. Or
in an another example, if you want to share your dotfiles with a containerized
process, you'd also need to share the Nix store in addition to your home
directory. Symlinking directly from a git repository under the home directory
would avoid this problem. Furthermore, it would allow for neat tricks like the
one used in the [rcd script](files/.local/bin/rcd).

### Use on non-Nix Systems

Most portion of this dotfiles should work just fine on systems without Nix.
However, some work is required to make everything work.

#### Install Packages

These packages would have to be installed manually.

- [Delta](https://github.com/dandavison/delta)
- [Fira Code](https://github.com/tonsky/FiraCode)
- [FZF](https://github.com/junegunn/fzf)
- [Neovim](https://neovim.io)
- [coc.nvim](https://github.com/neoclide/coc.nvim)
- [less](https://www.greenwoodsoftware.com/less/index.html) (version 530 or later)

#### Configure Git

Git username and email would have to be configured manually. Assuming the
information in [`config.toml`](../config.toml) is accurate, run the following
commands from the root of this repository after the first time you've run the
setup script:

```bash
git config -f ~/.config/git/user user.name "$(git config -f config.toml user.fullName)"
git config -f ~/.config/git/user user.email "$(git config -f config.toml user.email)"
```

Also if you wish to sign your commits:

```bash
git config -f ~/.config/git/user user.signingkey "$(git config -f config.toml user.gpgKey)"
git config -f ~/.config/git/user commit.gpgsign true
```

#### Configure GnuPG

Run the following command from the root of this repository:

```bash
sed "s/@gpgKey@/$(git config -f config.toml user.gpgKey)/g" \
  home/files/.gnupg/gpg.conf > ~/.gnupg/gpg.conf
```

#### Replace Nix dependant configuration

Apply [this patch](patches/debian.patch):

```bash
git apply patches/debian.patch
```

## Home Manager

### Overview

[Home Manager][home] is used to manage packages and daemons. It's also used as a
means to generate configuration files from high level definitions when the
convenience of doing so outweighs the benefits of using static dotfiles.

This document focuses on aspects that are unique to this dotfiles. Detailed
usage instructions for Home Manager itself can be found in the [official
manual][home-docs].

### Relationship with NixOS / nix-darwin

Home Manager is responsible for per-user settings while NixOS and nix-darwin
manages system wide settings. This dotfiles uses both.

When choosing where to place a given configuration, prefer Home Manager over
system wide configuration unless there's a reason not to. This would provide
the following benefits:

- Home Manager is usable on non-NixOS distros with Nix installed
- Home Manager can share configuration between Linux and macOS
- You can enjoy up to date packages with Home Manager while keeping the system
  packages in NixOS / nix-darwin stable

### Best Practices

When installing packages, prefer to install them on a per-project basis instead
of installing them globally through Home Manager to keep the Home Manager
configuration small. This can be achieved using a combination of the
[nix-shell][nix-shell] and [direnv][direnv]. [Direnv's wiki][direnv-wiki]
contains a detailed explanation about this setup. [nix-direnv][nix-direnv],
which further integrates the two, is also included as part of the Home Manager
configuration for this dotfiles.

### Configuration

| Directory              | Contents                             |
| ---------------------- | ------------------------------------ |
| [`modules`](modules)   | Contains custom Home Manager modules |
| [`profiles`](profiles) | Contains profiles                    |
| [`machines`](machines) | Contains configuration for each host |

A profile basically refers to a Home Manager module. The distinction is somewhat
arbitrary, but a module targeting a specific piece of software is placed in
`modules` while a module targeting a specific use case is placed in `profiles`.

The configuration for Home Manager is chosen based on the hostname unless a
specific one is chosen via the command line. Configuration for each host are
defined in [`machines`](machines), so make sure to add hosts as necessary. If no
configuration matching the hostname is found, the Home Manager would attempt to
find a match based on the username instead.

## How to add configuration for new hosts

Add them to [this file](machines/default.nix). Here's an example of how this
might look like for a host named `pod042`:

```nix
pod042 = mkHome {
  configuration = {
    dotfiles.profiles.enableAll = true;
  };
};
```

`mkHome` is a wrapper for [`homeManagerConfiguration`][home-conf] that bundles
custom Home Manager modules in this dotfiles repository.

There's also an `importHome` function that allows you to split out the
configuration into a separate file. To use this, replace `mkHome` with the
below:

```nix
pod042 = importHome ./pod042.nix { };
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

### Custom Options

This dotfiles introduces a few additional options for Home Manager, as outlined
below:

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

[home]: https://github.com/nix-community/home-manager
[home-conf]: https://github.com/nix-community/home-manager/blob/master/flake.nix
[home-docs]: https://nix-community.github.io/home-manager/
[nix-shell]: https://nixos.wiki/wiki/Development_environment_with_nix-shell
[direnv]: https://direnv.net
[direnv-wiki]: https://github.com/direnv/direnv/wiki/Nix
[nix-direnv]: https://github.com/nix-community/nix-direnv
