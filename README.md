# dotfiles

dotfiles for my personal use.

## Installation

### Step 1: Setup your repository

First, fork this repository and clone it to your location of choice. A helper
script is provided to help you change profile information for git, gpg, etc.
This script also registers a remote named `upstream` and points it to
[midchildan/dotfiles](https://github.com/midchildan/dotfiles). Make sure you
run this script in the `master` branch.

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
section, checkout the most relevant branch for your platform. It is recommended
that you create a `local` branch specific to your computer and check it out to
a separate path for deployment. This way, you can work on different branches
without affecting your current configuration.  Also, don't forget to merge
changes you've made at Step 1.

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

|branch |platform      |
|-------|--------------|
|master |Debian, Ubuntu|
|osx    |macOS         |
|nixos  |NixOS         |
|centos7|CentOS 7      |

In addition to the platforms listed above, support for one-off remote Linux
sessions is included in the `gh-pages` branch. See
[here](https://www.midchildan.org/dotfiles) for details.

Changes common to all platforms should first be made in `master`, and then
merged into the remaining branches. `master` should never merge changes from
other platform-specific branches or chaos would ensue.
