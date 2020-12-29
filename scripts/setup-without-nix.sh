#!/usr/bin/env bash

# Run this script if you ever want to setup the dotfiles without having Nix
# installed.

set -euo pipefail

NIX_PROFILE_DIR=~/.nix-profile
BIN_DIR="$NIX_PROFILE_DIR/bin"
DATA_DIR="$NIX_PROFILE_DIR/share"
OPT_DIR="$NIX_PROFILE_DIR/opt"
SHELLCONF_DIR="$NIX_PROFILE_DIR/etc/profile.d"
VIMPLUGIN_DIR="$NIX_PROFILE_DIR/share/vim-plugins"


main() {
  if has nix-env; then
    message::warn "Quitting because Nix is installed on this computer"
    exit 1
  fi
  if ! has nvim || [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    message::err "Quitting because Neovim or vim-plug isn't installed"
    exit 1
  fi

  message "Installing packages ..."

  mkdir -p \
    "$BIN_DIR" \
    "$DATA_DIR" \
    "$OPT_DIR" \
    "$SHELLCONF_DIR" \
    "$VIMPLUGIN_DIR"

  nvim -u NONE -S <(txt::update-packages.vim)

  txt::nix.sh > "$SHELLCONF_DIR/nix.sh"
  txt::fzf-share | writeScript "$BIN_DIR/fzf-share"
  ln -sf "$OPT_DIR/fzf" "$VIMPLUGIN_DIR/fzf"
  ln -sf "$OPT_DIR/coc-nvim" "$VIMPLUGIN_DIR/coc-nvim"
  ln -sf "$OPT_DIR/zsh-syntax-highlighting" "$DATA_DIR/zsh-syntax-highlighting"
  ln -sf "$VIMPLUGIN_DIR/fzf/bin/fzf-tmux" "$BIN_DIR/fzf-tmux"
  if [[ -x "$VIMPLUGIN_DIR/fzf/bin/fzf" ]]; then
    ln -sf "$VIMPLUGIN_DIR/fzf/bin/fzf" "$BIN_DIR/fzf"
  fi

  message "Installation complete"

  doctor

  message::tips "Run this script periodically to keep packages up-to-date."
  message::tips "To uninstall, run 'rm -rf $NIX_PROFILE_DIR'."
  message::tips "Make sure you uninstall if you ever decide to install Nix later on."
}

doctor() {
  message "Checking for potential problems ..."

  local n_diagnosis=0

  if has less; then
    if isOlderThan 530 "$(version::less)"; then
      message::err 'Detected an outdated version of less.'
      (( n_diagnosis += 1 ))
    fi
  else
    message::err "less not detected."
    (( n_diagnosis += 1 ))
  fi

  if has tmux; then
    if isOlderThan 3.1 "$(version::tmux)"; then
      message::err 'Detected an outdated version of tmux.'
      (( n_diagnosis += 1 ))
    fi
  else
    message::err "tmux not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has direnv; then
    message::err "direnv not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has rg; then
    message::err "ripgrep not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has node; then
    message::err "Node.js not detected. coc.nvim may not run without it."
    (( n_diagnosis += 1 ))
  fi

  if [[ ! -x /usr/local/bin/pinentry-mac ]]; then
    message::err "pinentry-mac not detected. Run 'brew install pinentry-mac' to install it."
    (( n_diagnosis += 1 ))
  fi

  if (( n_diagnosis == 0 )); then
    message::ok "No problems found."
  else
    message::warn "$n_diagnosis problem(s) detected."
    message::warn "Consider installing the latest versions for missing or outdated programs."
    message::warn "Alternatively, you could use old configs from git history for outdated programs."
  fi
}

txt::update-packages.vim() {
cat <<EOF
source ~/.vim/autoload/plug.vim
call plug#begin('$OPT_DIR')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim', {'branch': 'release', 'as': 'coc-nvim'}
Plug 'zsh-users/zsh-syntax-highlighting'
call plug#end()
PlugUpdate
only
redraw
echo "Waiting for 5 seconds..."
sleep 5
qall!
EOF
}

txt::nix.sh() {
cat <<EOF
export PATH="$NIX_PROFILE_DIR/bin:\$PATH"
EOF
}

txt::fzf-share() {
cat <<EOF
#!/usr/bin/env bash
echo "$VIMPLUGIN_DIR/fzf/shell"
EOF
}

writeScript() {
  cat > "$1"
  chmod +x "$1"
}

has() {
  command -v "$1" &> /dev/null
}

isOlderThan() {
  local required="$1"
  local current="$2"
  ! printf '%s\n' "$required" "$current" | sort -V -C
}

version::less() {
  less --version | head -n1 | cut -d' ' -f2
}

version::tmux() {
  tmux -V | head -n1 | cut -d' ' -f2
}

isUnicodeTerm() {
  printf "%s" "$LANG" "$(locale LC_CTYPE)" | grep -q UTF-8
}

message() {
  printf "%s\n" "$*" >&2
}

message::tips() {
  printf "💡 TIPS: %s\n" "$*" >&2
}

message::ok() {
  printf "✅ OKAY: %s\n" "$*" >&2
}

message::err() {
  printf "❌ FAIL: %s\n" "$*" >&2
}

message::warn() {
  printf "🔔 WARN: %s\n" "$*" >&2
}

main "$@"
