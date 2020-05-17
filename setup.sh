#!/usr/bin/env bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILE_DIR/scripts/setup"

# Remove dead symlinks
@clean
  - gc: true

@shell Update Submodules
  - git submodule --quiet update --init --remote

@install Install Shell Config
  - .bash_profile
  - .bashrc
  - .bash_logout
  - .zshenv
  - .zshrc
  - .zlogout
  - .inputrc
  - .config/shell/snippets/common.snip
  - .config/shell/snippets/linux.snip
  - .config/shell/templates
  - .config/shell/templates.csv
  - .local/share/zsh/site-functions

@install Install Vim Config
  - .vim
  - .config/nvim
  - download: \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      ~/.vim/autoload/plug.vim

@install Install Git Config
  - .config/git/config
  - .config/git/ignore
  - .config/tig/config
  - .local/bin/git-deploy
  - .local/bin/git-fancy
  - .local/bin/git-kitty

@install Install GPG Config
  - shell: install -d -m 700 ~/.gnupg
  - chmod: 700 .gnupg
  - chmod: 600 .gnupg/gpg.conf
  - chmod: 600 .gnupg/gpg-agent.conf
  - .gnupg/gpg.conf
  - .gnupg/gpg-agent.conf

@install Install SSH Config
  - shell: install -d -m 700 ~/.ssh ~/.ssh/sockets
  - chmod: 700 .ssh
  - .ssh/config
  - .ssh/config.d/10-canonicalize.conf
  - .ssh/config.d/80-git.conf
  - .ssh/config.d/90-general.conf
  - .ssh/config.d/90-multiplexing.conf
  - .local/bin/rcd

@install Install GDB Config
  - .gdbinit
  - .local/bin/gef
  - .local/bin/peda
  - .local/bin/pwndbg

@install Install LaTeX Config
  - .config/latexmk/latexmkrc
  - .local/bin/platexmk
  - .local/bin/uplatexmk

@install Install Emacs Config
  - github: hlissner/doom-emacs ~/.emacs.d
  - .config/doom/init.el
  - .config/doom/config.org
  - .config/doom/packages.el

@install Install VSCode Config
  - shell: install -d -m 700 ~/.config/Code
  - .config/Code/User/settings.json

@install Install Miscellaneous Config
  - .clang-format
  - .editrc
  - .ideavimrc
  - .config/bat/config
  - .config/kitty/kitty.conf
  - .config/nano/nanorc
  - .config/nixpkgs/config.nix
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/tilix/schemes/gruvbox-dark.json
  - .config/zathura/zathurarc
  - .docker/config.json
  - .ipython/profile_default/ipython_config.py
  - .local/libexec/fzf/install
  - .local/opt/fzftools
  - .local/opt/tmux-copycat
  - .screenrc
  - .tmux.conf
  - .wgetrc
  - .xprofile

# The below will not run unless --init is specified

@packages
  - init: true
  - build-essential
  - cmake
  - cmigemo
  - fonts-powerline
  - zsh-syntax-highlighting
  - shell: vim +PlugInstall +qall
  - shell: ~/.emacs.d/bin/doom -y install --no-config

@githooks
  - init: true
  - post-receive
