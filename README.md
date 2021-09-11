# dotfiles

dotfiles for my personal use.

## Requirements

### Nix Package Manager

Requires [Flakes](https://nixos.wiki/wiki/Flakes) to be enabled, which is
currently an experimental feature.

- [Official website](https://nixos.org)
- [Official docs](https://nixos.org/learn.html)

It's also possible to use this dotfiles on systems without Nix. If you wish to
do so, make sure to read [this document](home/README.md) before proceeding.

## Installation

### Step 1: Setup your repository

First, fork this repository and clone it to your location of choice. Then edit
`config.toml` and commit the changes.

```console
$ git clone https://github.com/${USER}/dotfiles.git ~/Documents/src/repos/github.com/${USER}/dotfiles
$ cd ~/Documents/src/repos/github.com/${USER}/dotfiles
$ vim config.toml
$ git commit -am 'chore: replace config.toml'
```

### Step 2: Checkout the relevant branch

Next, using the table in the [Supported Platforms](#supported-platforms)
section, checkout the most relevant branch for your platform. Note that instead
of checking out your chosen branch directly, it is recommended that you create a
`local` branch based on your chosen branch that is tied to your local machine
and check it out to a separate path for deployment. This way, you can edit files
on any branch without affecting your current configuration.

```console
$ git branch --track local  # create local branch
$ git worktree add ~/.config/dotfiles local  # checkout local branch
```

### Step 3: Bootstrap NixOS / Nix-Darwin / Home Manager Configuration

For details about each, read the docs linked below. To use this dotfiles on
systems without Nix, skip straight to the next step.

| Software     | File                                 |
| ------------ | ------------------------------------ |
| NixOS        | [nixos/README.md](nixos/README.md)   |
| Nix-Darwin   | [darwin/README.md](darwin/README.md) |
| Home Manager | [home/README.md](home/README.md)     |

The commands for bootstrapping each are listed below. Adjust settings for each
and run them as needed. For Nix 2.3 or below, run the commands in a nix-shell
with `nix-shell -A nixUnstable '<nixpkgs>'`.

- NixOS:

```console
$ sudo nix --experimental-feature 'nix-command flake' run '.#nixos' -- switch --flake '.#'
```

- nix-darwin:

```console
$ mkdir ~/Applications # https://github.com/LnL7/nix-darwin/pull/226
$ nix --experimental-features 'nix-command flakes' run '.#darwin' -- switch --flake '.#'
$ sudo -H nix-env -e '*' # remove existing packages not managed by nix-darwin
```

- Home Manager:

```console
$ nix --experimental-features 'nix-command flakes' run '.#home' -- switch --flake '.#'
```

### Step 4: Symlink dotfiles

Finally, run the setup script. This script would symlink files in
[home/files](home/files) to your home directory. It should be run each time
changes are made to your dotfiles. The `--init` flag means that this is the
first time you've run this script.

```console
$ cd ~/.config/dotfiles
$ ./setup.sh --init
```

## Supported platforms

| branch | platform |
| ------ | -------- |
| master | Linux    |
| osx    | macOS    |

In addition to the platforms listed above, support for one-off remote Linux
sessions is included in the `gh-pages` branch. This is useful in cases where
it's cumbersome to maintain a full-blown dotfiles, e.g. docker sessions, servers
you rarely login to directly, etc. See
[here](https://www.midchildan.org/dotfiles) for details.

Changes common to all platforms should first be made in `master`, and then
merged into the remaining branches. Make sure you never go the other way and
merge non-`master` branches into `master` or you'll end up with non-common
platform-specific stuff in `master`.
