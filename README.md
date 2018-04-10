dotfiles
========

dotfiles for my personal use.

Installation
------------

### Recommended

This method allows you to edit files or work on different branches without
affecting your current configuration. It works by creating two separate
worktrees, one for editing and the other for deployment.

#### Debian/Ubuntu

```sh
cd ~/Documents
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git branch --track local
git worktree add ~/.config/dotfiles local
cd ~/.config/dotfiles
./setup.sh --install-deps
```

#### NixOS

```sh
cd ~/Documents
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git checkout nixos
git branch --track local
git worktree add ~/.config/dotfiles local
cd ~/.config/dotfiles
./setup.sh --install-deps
```

#### macOS

```sh
cd ~/Documents
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git checkout osx
git branch --track local
git worktree add ~/Library/dotfiles local
cd ~/Library/dotfiles
./setup.sh --install-deps
```

### Simple

If you don't need a separate worktree for deployment, directly clone to the
deployment path instead.

#### Debian/Ubuntu

```sh
mkdir -p ~/.config
cd ~/.config
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
./setup.sh --install-deps
```

#### NixOS

```sh
mkdir -p ~/.config
cd ~/.config
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git checkout nixos
./setup.sh --install-deps
```

#### macOS

```sh
cd ~/Library
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git checkout osx
./setup.sh --install-deps
```
