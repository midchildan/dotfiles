#!/usr/bin/env bash
# shellcheck disable=SC2215

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=scripts/setup
source "$DOTFILE_DIR/scripts/setup"

# Remove dead symlinks
@clean
  - gc: true

@shell Update Submodules
  - git submodule --quiet update --init --remote

@install Install Nix Config
  - .config/nixpkgs/config.nix
  - .config/nixpkgs/home.nix
  - .config/nixpkgs/home.d/dotfiles

@install Install Shell Config
  - .bash_profile
  - .bashrc
  - .bash_logout
  - .zshenv
  - .zshrc
  - .zlogout
  - .inputrc
  - .config/shell/snippets/common
  - .config/shell/snippets/linux
  - .config/shell/snippets/main/common.md
  - .config/shell/snippets/main/linux.md
  - .config/shell/templates
  - .config/shell/templates.csv
  - .local/share/zsh/site-functions
  - .local/opt/tldr

@install Install Vim Config
  - .vim
  - .config/nvim
  - download: \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
      ~/.vim/autoload/plug.vim

@install Install Git Config
  - .config/git/attributes
  - .config/git/config
  - .config/git/ignore
  - .config/tig/config
  - .local/bin/git-deploy
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

@install Install LaTeX Config
  - .config/latexmk/latexmkrc
  - .local/bin/platexmk
  - .local/bin/uplatexmk

@install Install Emacs Config
  - github: hlissner/doom-emacs ~/.config/emacs
  - .config/doom/init.el
  - .config/doom/config.org
  - .config/doom/packages.el

@install Install VSCode Config
  - shell: install -d -m 700 ~/.config/Code
  - .config/Code/User/settings.json

@install Install Miscellaneous Config
  - .clang-format
  - .editrc
  - .gemrc
  - .ideavimrc
  - .config/bat/config
  - .config/broot/launcher/refused
  - .config/containers/containers.conf
  - .config/kitty/kitty.conf
  - .config/nano/nanorc
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/tilix/schemes/gruvbox-dark.json
  - .config/zathura/zathurarc
  - .docker/config.json
  - .ipython/profile_default/ipython_config.py
  - .local/opt/fzftools
  - .local/opt/tmux-copycat
  - .prettierrc
  - .screenrc
  - .tmux.conf
  - .wgetrc
  - .xprofile
  - .Xresources

# The below will not run unless --init is specified

@shell Install Packages
  - init: true
  - script: install-home-manager.sh
  - nvim --headless +PlugInstall +'%print' +qall
  - ~/.emacs.d/bin/doom -y install --no-config

@githooks
  - init: true
  - post-receive
