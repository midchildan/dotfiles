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
  - .zshenv
  - .zshrc
  - .inputrc
  - .config/shell/snippets/common.snip
  - .config/shell/snippets/macos.snip
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
  - Library/LaunchAgents/org.gnupg.gpg-agent.plist

@install Install SSH Config
  - shell: install -d -m 700 ~/.ssh ~/.ssh/sockets
  - chmod: 700 .ssh
  - .ssh/config
  - .ssh/config.d/10-canonicalize.conf
  - .ssh/config.d/80-git.conf
  - .ssh/config.d/90-general.conf
  - .ssh/config.d/90-multiplexing.conf
  - .local/bin/rcd

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
  - shell: install -d -m 700 ~/Library/Application\ Support/Code
  - Library/Application\ Support/Code/User/settings.json

@install Install Miscellaneous Config
  - .clang-format
  - .editrc
  - .ideavimrc
  - .config/bat/config
  - .config/kitty/kitty.conf
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/zathura/zathurarc
  - .docker/config.json
  - .ipython/profile_default/ipython_config.py
  - .local/bin/rmpkg
  - .local/bin/imgcat
  - .local/opt/fzftools
  - .local/opt/tmux-copycat
  - .nanorc
  - .screenrc
  - .tmux.conf
  - .wgetrc
  - Library/Application\ Support/AquaSKK/keymap.conf

# The below will not run unless --init is specified

@packages
  - init: true
  - cmake
  - cmigemo
  - fzf
  - ripgrep
  - zsh-completions
  - zsh-syntax-highlighting
  - cask: homebrew/cask-fonts/font-powerline-symbols
  - shell: vim +PlugInstall +qall
  - shell: ~/.emacs.d/bin/doom -y install --no-config

@githooks
  - init: true
  - post-receive
