# Nix

## Home Manager

This dotfiles uses [Home Manager](https://github.com/nix-community/home-manager)
to manage Nix packages. Machine-local configuration is generated in
`~/.config/nixpkgs/home.d/config.nix` when you run `setup.sh --init`.

To update packages, run:

```sh
nix-channel --update
home-manager switch
```

Note that packages installed outside of Home Manager would have to be updated
using Nix with `nix-env -u`. This is likely to be the case for Nix itself if you
chose the
[single user setup](https://nixos.org/manual/nix/stable/#sect-single-user-installation)
for installing Nix.

For further tips, consult the Home Manager's
[README](https://github.com/nix-community/home-manager/blob/master/README.md)
file.

## Home Manager Options

This dotfiles introduces a few additional options for Home Manager, as outlined
below. The actual code can be found in
[home/.config/nixpkgs/home.d/dotfiles](../home/.config/nixpkgs/home.d/dotfiles).

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

## Example Configuration

Place the following in `~/.config/nixpkgs/home.d/profiles.nix`:

```nix
{ ... }:

{
  profiles.essential.enable = true;
  profiles.debugTools.enable = true;
}
```
