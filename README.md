# Portable Dotfiles

A collection of single file dotfiles for one-off remote Linux sessions. For
any other uses, see [the full dotfiles
repository](https://github.com/midchildan/dotfiles).

## Quick Start

Download the dotfiles into a temporary directory and start a new shell.

```sh
source <(curl -sSfL https://www.midchildan.org/dotfiles/setup.sh)
```

## bash

```sh
bash --rcfile <(curl -sSfL https://www.midchildan.org/dotfiles/.bashrc)
```

## zsh

```sh
zsh -d
source <(curl -sSfL https://www.midchildan.org/dotfiles/.zshrc)
```

## vim

```sh
vim -u <(curl -sSfL https://www.midchildan.org/dotfiles/.vimrc)
```

## screen

```sh
screen -c <(curl -sSfL https://www.midchildan.org/dotfiles/.screenrc)
```

## tmux

```sh
tmux -f <(curl -sSfL https://www.midchildan.org/dotfiles/.tmux.conf)
```
