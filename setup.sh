#!/usr/bin/env bash

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILE_DIR/scripts/setup"

# Remove dead symlinks
@clean
  - gc: "${ENABLE_GC:-true}"
  # the rest of this section is kept for backwards compatibility
  - .gitconfig
  - .latexmkrc
  - .vimrc
  - .gvimrc
  - .config/shell/common.snip
  - .mikutter/plugin

@install Update Submodules
  - shell: git submodule update --init --remote

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
  - script: "$DOTFILE_DIR/scripts/macvim.sh"

@install Install Git Config
  - .config/git/config
  - .config/git/ignore
  - .config/tig/config
  - .local/libexec/diff-so-fancy/git-fancy

@install Install GPG Config
  - shell: install -d -m 700 ~/.gnupg
  - chmod: 700 .gnupg
  - chmod: 600 .gnupg/gpg.conf
  - chmod: 600 .gnupg/gpg-agent.conf
  - .gnupg/gpg.conf
  - .gnupg/gpg-agent.conf
  - Library/LaunchAgents/org.gnupg.gpg-agent.plist

@install Install GTK Config
  - .gtkrc-2.0
  - .themes/zuki-themes

@install Install LaTeX Config
  - .config/latexmk/latexmkrc
  - .local/bin/platexmk
  - .local/bin/uplatexmk

@install Install Spacemacs Config
  - github: syl20bnr/spacemacs ~/.emacs.d
  - .spacemacs

@install Install VSCode Config
  - shell: install -d -m 700 ~/Library/Application\ Support/Code
  - Library/Application\ Support/Code/User/settings.json

@install Install Miscellaneous Config
  - .clang-format
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/zathura/zathurarc
  - .ipython/profile_default/ipython_config.py
  - .local/bin/rmpkg
  - .local/bin/imgcat
  - .local/opt/fzftools
  - .local/opt/tmux-copycat
  - .nanorc
  - .screenrc
  - .tern-config
  - .tmux.conf
  - .wgetrc
  - Library/Application\ Support/AquaSKK/keymap.conf
  - Library/Preferences/bat/config

# Will not run unless --install-deps is specified
@packages
  - skip: "${SKIP_PACKAGES:-true}"
  - cmake
  - cmigemo
  - fzf
  - node
  - ripgrep
  - zsh-completions
  - zsh-syntax-highlighting
  - script: https://sh.rustup.rs
  - shell: vim +PlugInstall +qall
