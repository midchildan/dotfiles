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

install: shell config
  - .bash_profile
  - .bashrc
  - .zprofile
  - .zshenv
  - .zshrc
  - .hushlogin
  - .inputrc
  - .local/share/zsh/site-functions
  - .local/share/zsh/snippets/common
  - .local/share/zsh/snippets/osx
  - .local/share/zsh/snippets/dotfiles/common.md
  - .local/share/zsh/snippets/dotfiles/macos.md
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
  - .local/libexec/ssh-askpass
  - Library/LaunchAgents/com.openssh.ssh-askpass.plist

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
  - shell: install -d -m 700 ~/Library/Application\ Support/Code
  - Library/Application\ Support/Code/User/settings.json

install: miscellaneous config
  - .clang-format
  - .editrc
  - .prettierrc
  - .screenrc
  - .wgetrc
  - .config/bat/config
  - .config/broot/conf.hjson
  - .config/broot/launcher/refused
  - .config/containers/containers.conf
  - .config/gem/gemrc
  - .config/ideavim/ideavimrc
  - .config/ipython/profile_default/ipython_config.py
  - .config/kitty/kitty.conf
  - .config/nano/nanorc
  - .config/nixpkgs/config.nix
  - .config/nixpkgs/overlays/dotfiles.nix
  - .config/ranger/rc.conf
  - .config/ranger/scope.sh
  - .config/tmux/tmux.conf
  - .config/zathura/zathurarc
  - .local/bin/imgcat
  - .local/bin/uninstaller
  - Library/Application\ Support/AquaSKK/keymap.conf
  - Library/Application\ Support/iTerm2/DynamicProfiles/template.plist
  - Library/Developer/Xcode/UserData/IDETemplateMacros.plist

# The following will not run unless --init is specified

run: package installation
  - init: true
  - nvim --headless +PlugInstall +'%print' +qall
  - ~/.config/emacs/bin/doom -y install --no-config

githooks:
  - init: true
  - post-receive
