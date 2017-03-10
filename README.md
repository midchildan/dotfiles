dotfiles
========

dotfiles for my personal use.

Installation
------------

### Debian/Ubuntu

```sh
cd ~/Documents
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git branch --track local
git worktree add ~/.config/dotfiles local
cd ~/.config/dotfiles
./setup.sh --install-plugins
```

### macOS

```sh
cd ~/Documents
git clone https://github.com/midchildan/dotfiles.git
cd dotfiles
git checkout osx
git branch --track local
git worktree add ~/Library/dotfiles local
cd ~/Library/dotfiles
./setup.sh --install-plugins
```
