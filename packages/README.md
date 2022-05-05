# Packages

This directory contains custom Nix packages for my own use. Many of these
packages are used internally within this dotfiles, but it could also be built
and run independantly.

## Tips

This section lists some commands that you can use to try out the packages in
this dotfiles. The current working directory should be placed at the root of
this repository when you run these examples.

All of the examples in this section requires [Nix Flakes][1] to be enabled. More
info about the commands can be found [here][2].

- List packages in this flake:

```console
$ nix search
* packages.x86_64-linux.bpftrace (0.13.0)
  High-level tracing language for Linux eBPF

* packages.x86_64-linux.cloudfoundry-cli-6 (6-6.53.0)
  The official command line client for Cloud Foundry

* packages.x86_64-linux.curl-h3 (7.79.0)
  A command line tool for transferring files with URL syntax

* packages.x86_64-linux.neovim (0.6.0)
  Vim text editor fork focused on extensibility and agility

* packages.x86_64-linux.nghttp3 (2021-09-20)
  HTTP/3 library written in C

* packages.x86_64-linux.ngtcp2 (2021-09-20)
  Implemenatation of the IETF QUIC protocol

* packages.x86_64-linux.nixos-rebuild

* packages.x86_64-linux.noto-serif-cjk (2021-10-27)
  Beautiful and free fonts for CJK languages

* packages.x86_64-linux.quictls (1.1.1l+quic)
  A cryptographic library that implements the SSL and TLS protocols

* packages.x86_64-linux.siege (4.1.1)
  HTTP load tester

* packages.x86_64-linux.terminfo-collection
  Collection of terminfo definitions

* packages.x86_64-linux.zsh (5.8)
  The Z shell. This package is intended for use on stable Linux distributions shipping an outdated version of zsh.
```

- Build and run the Neovim package:

```console
$ nix build '.#neovim'
$ ./result/bin/nvim --version | head -n1
NVIM v0.5.0
```

- Run Neovim without creating the `result` symlink:

```console
$ nix run '.#neovim' --version | head -n1
NVIM v0.5.0
```

[1]: https://nixos.wiki/wiki/Flakes
[2]: https://nixos.org/manual/nix/unstable/command-ref/experimental-commands.html
