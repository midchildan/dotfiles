# dotfiles

dotfiles for my personal use.

## Requirements

### Nix Package Manager

The [Nix package manager](https://nixos.org) works across macOS and various
Linux distributions, and can co-exist with native package managers. Having it
installed would ensure that this dotfiles would work on a wide range of systems
by bringing with it a high number of up-to-date packages that
[outnumbers any other package repositories](https://repology.org/repositories/statistics/newest).

See [here](https://nixos.org/learn.html) to get started. For usage with this
dotfiles, see [docs/nix.md](docs/nix.md).

#### But what if I don't want Nix?

There's an experimental script,
[setup-without-nix.sh](scripts/setup-without-nix.sh) that you can optionally run
after you've completed the installation process. This would take care of the
issues which arise from the lack of Nix.

### Fira Code

[Fira Code](https://github.com/tonsky/FiraCode) is the recommended font.
Ligatures aren't enabled. If you don't like Fira Code for whatever reason,
there's a [patch](patches/font-menlo.patch) to use Menlo instead.

## Installation

### Step 1: Setup your repository

First, fork this repository and clone it to your location of choice. Then run
the script, `./scripts/fork.sh`, to help you make the minimal changes necessary
to get you started. Make sure you first run this script in the `master` branch,
and merge it to the remaining branches.

```console
$ git clone https://github.com/${USER}/dotfiles.git ~/Documents/dotfiles
$ cd ~/Documents/dotfiles
$ ./scripts/fork.sh
Enter your name: John Doe
Enter your email: john@example.com
Enter your GPG key id (leave empty if none):
Patching...
Registering remote 'upstream'...
Complete! You can commit the changes by running:
  export GIT_AUTHOR_NAME="John Doe"
  export GIT_COMMITTER_NAME="John Doe"
  export EMAIL="john@example.com"
  git commit -am 'replace profile information'
$ export GIT_AUTHOR_NAME="John Doe"
$ export GIT_COMMITTER_NAME="John Doe"
$ export EMAIL="john@example.com"
$ git commit -am 'replace profile information'
```

### Step 2: Checkout the relevant branch

Next, using the table in the [Supported Platforms](#supported-platforms)
section, checkout the most relevant branch for your platform. Note that instead
of checking out your chosen branch directly, it is recommended that you create a
`local` branch based on your chosen branch that is tied to your local machine
and check it out to a separate worktree for deployment. This way, you can edit
files on different branches without affecting your current configuration. Also,
if you haven't yet merged the changes from step 1, you should do so now.

```console
$ git checkout nixos
$ git merge master  # merge changes from Step 1
$ git branch --track local  # create local branch
$ git worktree add ~/.config/dotfiles local  # checkout local branch
```

### Step 3: Run the setup script

Finally, run the setup script. This script should be run each time changes are
made to your dotfiles. The `--init` flag means that this is the first time
you've run this script.

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
