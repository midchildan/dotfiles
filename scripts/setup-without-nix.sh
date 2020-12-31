#!/usr/bin/env bash

# Run this script if you ever want to setup the dotfiles without having Nix
# installed.

set -Eeuo pipefail

PROFILE_DIR=~/.nix-profile
BIN_DIR="$PROFILE_DIR/bin"
DATA_DIR="$PROFILE_DIR/share"
OPT_DIR="$PROFILE_DIR/opt"
SHELLCONF_DIR="$PROFILE_DIR/etc/profile.d"
VIMPLUGIN_DIR="$PROFILE_DIR/share/vim-plugins"
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

  if ! prerunCheck; then
    exit 1
  fi

  msg "This script will use Homebrew and vim-plug to install packages in $PROFILE_DIR."
  msg "Installing packages. This may take a while ..."

  mkdir -p "$OPT_DIR"

  brew install fzf less zsh-syntax-highlighting >&2
  nvim --headless -u NONE -S <(txt::update-packages.vim) 2>&1 \
    | sed 's/^/nvim: /' >&2

  # Delete everything in PROFILE_DIR except opt/.
  (shopt -s extglob; eval 'rm -rf "${PROFILE_DIR:?}"/!(opt)')

  mkdir -p "$BIN_DIR" "$DATA_DIR" "$SHELLCONF_DIR" "$VIMPLUGIN_DIR"
  txt::hm-session-vars.sh | writeFile "$SHELLCONF_DIR/hm-session-vars.sh"
  txt::fzf-share | writeScript "$BIN_DIR/fzf-share"
  ln -sf "/usr/local/opt/fzf" "$VIMPLUGIN_DIR/fzf"
  ln -sf "$OPT_DIR/coc-nvim" "$VIMPLUGIN_DIR/coc-nvim"
  ln -sf "/usr/local/share/zsh-syntax-highlighting" "$DATA_DIR/zsh-syntax-highlighting"

  msg "Installation complete"

  doctor

  msg::tips "Run this script periodically to keep packages and generated configs up-to-date."
  msg::tips "To uninstall, run 'rm -rf $PROFILE_DIR'."
  msg::tips "Make sure you uninstall if you ever decide to install Nix later on."
  msg::warn "DO NOT put files in $PROFILE_DIR because it will be deleted upon next run."
}

prerunCheck() {
  if has nix-env; then
    msg::warn "Refusing to run because Nix is installed on this computer."
    return 1
  fi
  if [[ -L "$PROFILE_DIR" && "$(readlink "$PROFILE_DIR")" == /nix/* ]]; then
    msg::warn "Refusing to run because $PROFILE_DIR points to a path in /nix"
    return 1
  fi
  if ! has nvim || [[ ! -f ~/.vim/autoload/plug.vim ]]; then
    msg::err "Refusing to run because Neovim or vim-plug isn't installed."
    return 1
  fi
  if ! has brew; then
    msg::err "Refusing to run because Homebrew isn't installed."
    return 1
  fi

  if [[ -n "$IS_DRYRUN" ]]; then
    msg::warn "This is a dry run. No changes to the filesystem would be made."
  fi
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

  if [[ ! -x /usr/local/bin/pinentry-mac ]]; then
    msg::err "pinentry-mac not detected. Run 'brew install pinentry-mac' to install it."
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
    echo "Will update " . a:repo
  endf
  fun! plug#end()
  endf
  command! -nargs=+ -bar Plug call plug#(<args>)
  command! -bang -bar PlugClean echo 'Removed unused packages.'
  command! -bang -bar PlugUpdate echo 'Updated packages.'
endif

call plug#begin('$OPT_DIR')
Plug 'neoclide/coc.nvim', {'branch': 'release', 'as': 'coc-nvim'}
call plug#end()

PlugClean!
if "$IS_DRYRUN" == ""
  %print
  echo "\\n"
endif
PlugUpdate
if "$IS_DRYRUN" == ""
  echo
  %print
endif

qall!
EOF
}

txt::hm-session-vars.sh() {
  local build_path
  # Globs might not match at runtime. When it doesn't, just re-run this script.
  build_path="$(shopt -s nullglob; printf '%s:' \
    "$PROFILE_DIR/bin" \
    /usr/local/opt/python@3/bin \
    "\$PATH" \
    "\$HOME/.cargo/bin" \
    ~/Library/Python/*/bin \
    ~/.gem/ruby/*/bin \
  )"
cat <<EOF
export PATH="${build_path%%:}"
EOF
}

txt::fzf-share() {
cat <<EOF
#!/usr/bin/env bash
echo "/usr/local/opt/fzf/shell"
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

brew() {
  if [[ -z "$IS_DRYRUN" ]]; then
    command brew "$@"
  else
    msg "Run brew $*"
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

rm() {
  if [[ -z "$IS_DRYRUN" ]]; then
    command rm "$@"
  else
    msg "Run rm $*"
  fi
}

usage() {
cat <<EOF
A tool to install minimum required packages without Nix.
Requires Homebrew, Neovim, and vim-plug.

usage: ${0##*/} [options]

options:
  -h, --help		Print help message and exit
  -n, --dry-run		Do a trial run without making any persistent changes
EOF

exit
}

main "$@"
