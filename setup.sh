#!/usr/bin/env bash
# shellcheck disable=SC2215

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILE_FILES_DIR=files

# shellcheck source=scripts/lib/setup
source "$DOTFILE_DIR/scripts/lib/setup"

# Remove dead symlinks
clean:
  - gc: true

run: submodule updates
  - git submodule --quiet update --init

install: Nix config
  - .config/nix/nix.conf
  - .config/nixpkgs/config.nix
  - .config/nixpkgs/overlays/dotfiles.nix

install: shell config
  - .bash_profile
  - .bashrc
  - .bash_logout
  - .zshenv
  - .zshrc
  - .zlogout
  - .inputrc
  - .local/share/zsh/fzf-sources
  - .local/share/zsh/site-functions
  - .local/share/zsh/snippets/common
  - .local/share/zsh/snippets/linux
  - .local/share/zsh/snippets/dotfiles/common.md
  - .local/share/zsh/snippets/dotfiles/linux.md
  - .local/opt/tldr

install: Vim config
  - .vim
  - .config/nvim
  - download: \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      ~/.vim/autoload/plug.vim

install: Git config
  - .config/git/attributes
  - .config/git/config
  - .config/git/ignore
  - .config/tig/config
  - .local/bin/git-deploy
  - .local/bin/git-kitty

install: SSH config
  - shell: install -d -m 700 ~/.ssh ~/.ssh/sockets
  - chmod: 700 .ssh
  - .ssh/config
  - .ssh/config.d/10-canonicalize.conf
  - .ssh/config.d/80-git.conf
  - .ssh/config.d/90-general.conf
  - .ssh/config.d/90-multiplexing.conf
  - .local/bin/rcd

install: container config
  - .config/containers/containers.conf
  - .config/distrobox/distrobox.conf
  - .local/libexec/distrobox/nix.sh

install: GDB config
  - .gdbinit
  - .local/bin/gef
  - .local/bin/peda

install: LaTeX config
  - .config/latexmk/latexmkrc
  - .local/bin/platexmk
  - .local/bin/uplatexmk

install: Emacs config
  - github: doomemacs/doomemacs ~/.config/emacs
  - .config/doom/init.el
  - .config/doom/config.org
  - .config/doom/packages.el

install: VSCode config
  - shell: install -d -m 700 ~/.config/Code
  - .config/Code/User/settings.json

install: miscellaneous config
  - .clang-format
  - .editrc
  - .prettierrc
  - .screenrc
  - .wgetrc
  - .xprofile
  - .Xresources
  - .config/bat/config
  - .config/broot/conf.hjson
  - .config/broot/launcher/refused
  - .config/gem/gemrc
  - .config/ideavim/ideavimrc
  - .config/ipython/profile_default/ipython_config.py
  - .config/kitty/kitty.conf
  - .config/nano/nanorc
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/tmux/tmux.conf
  - .config/zathura/zathurarc

# The following will not run unless --init is specified

run: package installation
  - init: true
  - nvim --headless +PlugInstall +'%print' +qall
  - ~/.config/emacs/bin/doom -y install --no-config

githooks:
  - init: true
  - post-receive
