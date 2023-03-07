# dotfiles

dotfiles for my personal use.

_The `master` branch has been discontinued. Check out the `main` branch
instead._

## Requirements

### Nix Package Manager

Consult the following for more details.

- [Official website](https://nixos.org)
- [Official docs](https://nixos.org/learn.html)

Nix can be installed on a wide range of Linux distros and even on macOS. It can
painlessly coexist with existing system package managers. However, if you wish
to stick with the package manager that you already have, it's also possible to
use this dotfiles on systems without Nix albeit with reduced compatibility
guarantees. If you wish to do so, make sure to read
[this document](home/README.md) before proceeding.

## Installation

### Step 1: Preparation

#### With Nix

Drop into a [nix-shell][nix-shell] with the following command. This would
download some commands required for setup, open a new temporary shell, and make
the commands available through `PATH`.

```console
$ system="$(nix-instantiate --eval -E 'builtins.currentSystem' | tr -d '"')"
$ nix-shell -A "devShells.$system.setup" 'https://github.com/midchildan/dotfiles/archive/master.tar.gz'
$
```

#### Without Nix

Make sure the following commands are installed beforehand.

- Git
- cURL or Wget
- Neovim

Neovim is used to install Vim plugins at the end of the installation. If you
wish to use Vim instead, you can do so manually by invoking
[`:PlugInstall`][plug] in Vim.

### Step 2: Setup your repository

Fork this repository and clone it to your location of choice. Then edit
`config.toml` and commit the changes.

```console
$ git clone https://github.com/${USER}/dotfiles.git ~/Documents/src/repos/github.com/${USER}/dotfiles
$ cd ~/Documents/src/repos/github.com/${USER}/dotfiles
$ nvim config.toml
$ git commit -am 'chore: adjust config.toml for my own use'
```

### Step 3: Checkout the relevant branch

Using the table in the [Supported Platforms](#supported-platforms) section,
checkout the most relevant branch for your platform. Note that instead of
checking out your chosen branch directly, it is recommended that you create a
`local` branch based on your chosen branch that is tied to your local machine
and check it out to a separate path for deployment. This way, you can make edits
on any branch without affecting your current configuration.

```console
$ git branch --track local  # create local branch
$ git worktree add ~/.config/dotfiles local  # checkout local branch
```

### Step 4: Symlink dotfiles

Run the setup script. This script would symlink files in
[home/files](home/files) to your home directory. It should be run each time
changes are made to your dotfiles even after bootstrapping is complete. The
`--init` flag indicates that this is the first time you've run this script.

```console
$ ./setup.sh --init
```

If you're using Nix, proceed to the next step. Otherwise, bootstrapping is
complete.

### Step 5: Bootstrap NixOS / Nix-Darwin / Home Manager Configuration

For details about each, read the docs linked below. Pick the ones you need and
configure them as needed before proceeding.

| Software     | File                                 | Required? |
| ------------ | ------------------------------------ | --------- |
| Home Manager | [home/README.md](home/README.md)     | yes       |
| NixOS        | [nixos/README.md](nixos/README.md)   | no        |
| Nix-Darwin   | [darwin/README.md](darwin/README.md) | no        |

Bootstrapping instructions for each are listed below. Home Manager can
optionally be integrated into NixOS or Nix-Darwin. If you do this, NixOS or
Nix-Darwin would take care of bootstrapping Home Manager for you. Otherwise if
you're bootstrapping Home Manager yourself, make sure to enable [Nix
flakes][flakes] beforehand.

- Home Manager:

```console
$ nix run '.#home' -- switch --flake .
```

- NixOS:

```console
$ sudo nix --experimental-features 'nix-command flakes' run '.#nixos' -- switch --flake '.#'
```

- nix-darwin:

```console
$ mkdir ~/Applications # https://github.com/LnL7/nix-darwin/pull/226
$ nix --experimental-features 'nix-command flakes' run '.#darwin' -- switch --flake '.#'
$ sudo -H nix-env -e '*' # remove existing packages not managed by nix-darwin
```

## Supported platforms

| branch | platform |
| ------ | -------- |
| master | Linux    |
| osx    | macOS    |

In addition to the platforms listed above, support for one-off remote Linux
sessions is included in the `gh-pages` branch. This is useful in cases where
it's cumbersome to maintain a full-blown dotfiles, e.g. docker sessions, servers
you rarely login to directly, etc. Notably, this branch doesn't require Nix. See
[here](https://www.midchildan.org/dotfiles) for details.

Changes common to all platforms should first be made in `master`, and then
merged into the remaining branches. Make sure you never go the other way and
merge non-`master` branches into `master` or you'll end up with non-common
platform-specific stuff in `master`.

[nix-shell]: https://nixos.wiki/wiki/Development_environment_with_nix-shell
[plug]: https://github.com/junegunn/vim-plug#commands
[flakes]: https://nixos.wiki/wiki/Flakes
