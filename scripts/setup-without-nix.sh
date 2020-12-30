#!/usr/bin/env bash

# Run this script if you ever want to setup the dotfiles without having Nix
# installed.

set -Eeuo pipefail

NIX_PROFILE_DIR=~/.nix-profile
BIN_DIR="$NIX_PROFILE_DIR/bin"
DATA_DIR="$NIX_PROFILE_DIR/share"
OPT_DIR="$NIX_PROFILE_DIR/opt"
SHELLCONF_DIR="$NIX_PROFILE_DIR/etc/profile.d"
VIMPLUGIN_DIR="$NIX_PROFILE_DIR/share/vim-plugins"
IS_DRYRUN=

handleError() {
  trap - ERR
  msg::err "$(caller): ${BASH_COMMAND}"
}
trap handleError ERR


main() {
  for n in "$@"; do
    case "$n" in
      -h|--help) usage ;;
      -n|--dry-run) IS_DRYRUN=1 ;;
      *) ;;
    esac
  done

  if has nix-env; then
    msg::warn "Refusing to run because Nix is installed on this computer."
    exit 1
  fi
  if ! has nvim || [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    msg::err "Refusing to run because Neovim or vim-plug isn't installed."
    exit 1
  fi
  if [[ -n "$IS_DRYRUN" ]]; then
    msg::warn "This is a dry run. No changes to the filesystem would be made."
  fi

  msg "This script will use vim-plug to install packages in $NIX_PROFILE_DIR."
  msg "Installing packages. This may take a while ..."

  mkdir -p \
    "$BIN_DIR" \
    "$DATA_DIR" \
    "$OPT_DIR" \
    "$SHELLCONF_DIR" \
    "$VIMPLUGIN_DIR"

  nvim --headless -u NONE -S <(txt::update-packages.vim) 2>&1 \
    | sed 's/^/nvim: /' >&2

  txt::nix.sh | writeFile "$SHELLCONF_DIR/nix.sh"
  txt::fzf-share | writeScript "$BIN_DIR/fzf-share"
  ln -sf "$OPT_DIR/fzf" "$VIMPLUGIN_DIR/fzf"
  ln -sf "$OPT_DIR/coc-nvim" "$VIMPLUGIN_DIR/coc-nvim"
  ln -sf "$OPT_DIR/zsh-syntax-highlighting" "$DATA_DIR/zsh-syntax-highlighting"
  ln -sf "$VIMPLUGIN_DIR/fzf/bin/fzf-tmux" "$BIN_DIR/fzf-tmux"
  if [[ -x "$VIMPLUGIN_DIR/fzf/bin/fzf" ]]; then
    ln -sf "$VIMPLUGIN_DIR/fzf/bin/fzf" "$BIN_DIR/fzf"
  fi

  msg "Installation complete"

  doctor

  msg::tips "Run this script periodically to keep packages up-to-date."
  msg::tips "To uninstall, run 'rm -rf $NIX_PROFILE_DIR'."
  msg::tips "Make sure you uninstall if you ever decide to install Nix later on."
}

doctor() {
  msg "Checking for potential problems ..."

  local n_diagnosis=0

  if has less; then
    if isOlderThan 530 "$(version::less)"; then
      msg::err 'Detected an outdated version of less.'
      (( n_diagnosis += 1 ))
    fi
  else
    msg::err "less not detected."
    (( n_diagnosis += 1 ))
  fi

  if has tmux; then
    if isOlderThan 3.1 "$(version::tmux)"; then
      msg::err 'Detected an outdated version of tmux.'
      (( n_diagnosis += 1 ))
    fi
  else
    msg::err "tmux not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has direnv; then
    msg::err "direnv not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has rg; then
    msg::err "ripgrep not detected."
    (( n_diagnosis += 1 ))
  fi

  if ! has node; then
    msg::err "Node.js not detected. coc.nvim may not run without it."
    (( n_diagnosis += 1 ))
  fi

  if (( n_diagnosis == 0 )); then
    msg::ok "No problems found."
  else
    msg::warn "$n_diagnosis problem(s) detected."
    msg::warn "Consider installing the latest versions for missing or outdated programs."
    msg::warn "For outdated programs, you could also use old configs from git history."
  fi
}

txt::update-packages.vim() {
cat <<EOF
source ~/.vim/autoload/plug.vim
if "$IS_DRYRUN" != ""
  fun! plug#begin(dir)
    echo "Installing packages to " . a:dir
  endf
  fun! plug#(repo, ...)
    echo "Installed " . a:repo
  endf
  fun! plug#end()
  endf
  command! -nargs=+ -bar Plug call plug#(<args>)
  command! -bar PlugUpdate call plug#end()
endif

call plug#begin('$OPT_DIR')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'neoclide/coc.nvim', {'branch': 'release', 'as': 'coc-nvim'}
Plug 'zsh-users/zsh-syntax-highlighting'
call plug#end()

PlugUpdate
if "$IS_DRYRUN" == ""
  echo
  %print
endif

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

msg() {
  printf "%s\n" "$*" >&2
}

msg::tips() {
  printf "💡 TIPS: %s\n" "$*" >&2
}

msg::ok() {
  printf "✅ OKAY: %s\n" "$*" >&2
}

msg::err() {
  printf "❌ FAIL: %s\n" "$*" >&2
}

msg::warn() {
  printf "🔔 WARN: %s\n" "$*" >&2
}

writeFile() {
  if [[ -z "$IS_DRYRUN" ]]; then
    cat > "$1"
  else
    cat > /dev/null # consume stdin
    msg "Wrote file $1"
  fi
}

writeScript() {
  if [[ -z "$IS_DRYRUN" ]]; then
    cat > "$1"
    chmod +x "$1"
  else
    cat > /dev/null # consume stdin
    msg "Wrote script $1"
  fi
}

ln() {
  if [[ -z "$IS_DRYRUN" ]]; then
    command ln "$@"
  else
    msg "Run ln $*"
  fi
}

mkdir() {
  if [[ -z "$IS_DRYRUN" ]]; then
    command mkdir "$@"
  else
    msg "Run mkdir $*"
  fi
}

usage() {
cat <<EOF
A tool to install minimum required packages without Nix.
Requires Neovim and vim-plug.

usage: ${0##*/} [options]

options:
  -h, --help		Print help message and exit
  -n, --dry-run		Do a trial run without making any persistent changes
EOF

exit
}

main "$@"
