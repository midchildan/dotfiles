# nix-darwin

On macOS, this dotfiles uses [nix-darwin][1] to manage Nix itself. For those
familiar with [NixOS][2], nix-darwin brings the [NixOS configuration system][3]
to macOS.  In contrast to [Home Manager][3], which mainly concerns itself with
user configuration, nix-darwin is is used to manage system-wide configuration.

To update Nix and/or nix-darwin configuration, run:

```sh
nix-channel --update
darwin-rebuild switch
```

For further tips, consult the nix-darwin's [README][4] file.

## nix-darwin Options

This dotfiles introduces a few additional options for nix-darwin, as outlined
below. The actual code can be found in [home/.config/nixpkgs/darwin.d/dotfiles][5].

<dl>
  <dt>dotfiles.profiles.apps.enable</dt>
  <dd>
    Installs essential macOS applications. Since this feature relies on
    <a href="https://github.com/Homebrew/homebrew-cask">Hombrew Cask</a>,
    <a href="https://brew.sh">Homebrew</a> would need to be installed beforehand
    when enabling this module. Note that by enabling this option, Homebrew
    formulae/casks not present in nix-darwin configuration would be uninstalled
    automatically by default.
  </dd>
</dl>

## Example Configuration

Place the following in `~/.config/nixpkgs/darwin.d/profiles.nix`:

```nix
{ ... }:

{
  profiles.apps.enable = true;
}
```
[1]: https://github.com/LnL7/nix-darwin
[2]: https://nixos.org
[3]: https://github.com/nix-community/home-manager
[4]: https://github.com/LnL7/nix-darwin/blob/master/README.md
[5]: ../home/.config/nixpkgs/darwin.d/dotfiles
