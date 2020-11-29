# Nix

## Home Manager

This dotfiles uses [Home Manager](https://github.com/nix-community/home-manager)
to manage Nix packages.

To update packages, run:

```sh
nix-channel --update
home-manager switch
```

See the
[README](https://github.com/nix-community/home-manager/blob/master/README.md)
for more info.

## Home Manager Options

<dl>
  <dt>targets.genericLinux.enable</dt>
  <dd>
    Enable this option when using distros other than NixOS. Disabled by default.
  </dd>
  <dt>programs.dotfiles.minimal.enable</dt>
  <dd>
    Installs the bare minimum amount of packages needed for the dotfiles to
    function. Enabled by default.
  </dd>
  <dt>programs.dotfiles.essential.enable</dt>
  <dd>
    Installs essential packages for servers and desktops alike. Disabled by
    default.
  </dd>
  <dt>programs.dotfiles.development.enable</dt>
  <dd>
    Installs development packages. Disabled by default.
  </dd>
  <dt>programs.dotfiles.debugTools.enable</dt>
  <dd>
    Installs debugging tools. Disabled by default.
  </dd>
  <dt>programs.dotfiles.desktop.enable</dt>
  <dd>
    Installs essential packages for NixOS desktops. Disabled by default.
  </dd>
</dl>

## Example Configuration

Place the following in `~/.config/nixpkgs/home.d/config.nix`:

```nix
{ ... }:

{
  programs.dotfiles.essential.enable = true;
  programs.dotfiles.debugTools.enable = true;
  targets.genericLinux.enable = true;
}
```
