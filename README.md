# Portable Dotfiles

A collection of single file dotfiles for one-time shell sessions. Convenient
when dealing with disposable shell sessions or SSH servers with only default
configs for frequently used unix tools.

This only aims to provide the bare minimum amount of configuration required to
obtain a usable shell environment, and is intended for single use. For a more
complete solution, see the
[full dotfiles repository](https://github.com/midchildan/dotfiles) which this
is based on.

The dotfiles are distributed under the terms of the
[Unlicense](https://unlicense.org).

## Quick Start

Download the dotfiles into a temporary directory and start a new shell. The
`$SHELL` environment variable would be used to determine which shell to start.
This could be overridden with the `-s` option.

```sh
source <(curl -sSfL https://www.midchildan.org/dotfiles/setup.sh)
```

It is also possible to download the dotfiles permanantly to a preferred location
using the `-d` option. However, this should be used with caution as it would
overwrite any existing files.

```sh
source <(curl -sSfL https://www.midchildan.org/dotfiles/setup.sh) -d ~
```

## More One-Liners
### zsh

Unfortunately, zsh has no way to directly specify an alternate path for its
`.zshrc` file, making one-liners using process substitution difficult. Just
start a new shell and `source` the configuration in two separate steps.

```sh
ZDOTDIR=/dev/null zsh
source <(curl -sSfL https://www.midchildan.org/dotfiles/.zshrc)
```

### bash

```sh
bash --rcfile <(curl -sSfL https://www.midchildan.org/dotfiles/.bashrc)
```

### vim

```sh
vim -u <(curl -sSfL https://www.midchildan.org/dotfiles/.vimrc)
```

### screen

```sh
screen -c <(curl -sSfL https://www.midchildan.org/dotfiles/.screenrc)
```

### tmux

```sh
tmux -f <(curl -sSfL https://www.midchildan.org/dotfiles/.tmux.conf)
```
