# Templates

This directory contains templates for creating new [Nix flakes][nix-flakes]. The
templates provided here are mainly useful for creating private configurations
that can make use of code provided in this dotfiles flake.

For example, to create a new flake based on the `nixos` template, run the
following command:

```console
$ nix flake init -t github:midchildan/dotfiles#nixos
```

[nix-flakes]: https://nixos.wiki/wiki/Flakes
