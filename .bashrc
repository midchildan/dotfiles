# shellcheck disable=SC1090,SC1091,SC2039

##########################
#  Early Initialization  #
##########################

# Setup some environment variables before the interactivity check. This is the
# only place where you can place startup commands that will be picked up by
# non-interactive SSH sessions.
#
# https://www.gnu.org/software/bash/manual/bash.html#Invoked-by-remote-shell-daemon

export EDITOR="vim"
export LANG="en_US.UTF-8"
export LESS="iMR"
export PAGER="less"
export SYSTEMD_LESS="iRSMK"

# skip the rest for non-interactive sessions
case $- in
  *i*) ;;
  *) return ;;
esac

###########################
#  Aliases and Functions  #
###########################
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias ssh-fa='ssh-agent ssh -o AddKeysToAgent=confirm -o ForwardAgent=yes'

::tmux() {
  local baseurl="https://www.midchildan.org/dotfiles/patches"
  local confdir="${DOTROOT:-$HOME}"
  if [[ -z "$_TMUXVER" && -f "$confdir/.tmux.conf" && "$1" != "current" ]]; then
    curl -sSfL "$baseurl/tmux-$1.patch" \
      | patch -d "$confdir" -p1 \
      && _TMUXVER="$1"
  fi
  command tmux -f "$confdir/.tmux.conf" "${@:2}"
}

tmux-2.6() { ::tmux 2.6 "$@"; }
tmux-2.8() { ::tmux 2.8 "$@"; }
tmux-3.1() { ::tmux 3.1 "$@"; }
tmux-3.0() { ::tmux current "$@"; }
tmux() { ::tmux current "$@"; }

if ! command -v neofetch >/dev/null 2>&1; then
  neofetch() {
    curl -sSfL "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" \
      | bash -s -- --no_config "$@"
  }
fi

#################
#  Keybindings  #
#################
# XXX: keybindings should be kept in sync with .inputrc
# completion
bind 'set colored-stats on'
bind 'set completion-ignore-case on'
bind 'set completion-map-case on'
bind 'set menu-complete-display-prefix on'
bind 'set show-all-if-ambiguous on'
bind 'set skip-completed-text on'
bind 'set visible-stats on'

# editing
bind 'set editing-mode vi'
bind 'set history-size 2000'
bind 'set bind-tty-special-chars off'

bind 'set keymap vi-command'
bind '"\C-l": clear-screen'
bind '"\C-w": edit-and-execute-command'

bind 'set keymap vi-insert'
bind 'TAB: menu-complete'
bind '"\e[Z": menu-complete-backward'
bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind '"\C-w": backward-kill-word'
bind '"\C-x\C-f": complete-filename'
bind '"\C-x\C-n": dynamic-complete-history'

######################
#  Terminal Support  #
######################
case "$TERM" in
  xterm*|screen*|tmux*)
    __vte_urlencode() {
      # Use LC_CTYPE=C to process text byte-by-byte.
      local LC_CTYPE=C LC_ALL='' raw_url="$1" safe
      while [[ -n "$raw_url" ]]; do
        safe="${raw_url%%[!a-zA-Z0-9/:_\.\-\!\'\(\)~]*}"
        printf "%s" "$safe"
        raw_url="${raw_url#"$safe"}"
        if [[ -n "$raw_url" ]]; then
          printf "%%%02X" "'$raw_url"
          raw_url="${raw_url#?}"
        fi
      done
    }

    # report working directory
    __vte_osc7() {
      printf "\e]7;file://%s%s\a" "${HOSTNAME:-}" "$(__vte_urlencode "$PWD")"
    }

    # deal with missing line feeds from previous command
    __print_missing_lf() {
      # XXX: This might not sit well with misbehaving terminals. It also messes
      # up output on window resize, but I decided to just live with it for now
      # because only a few applications fail to output a trailing newline.
      # FWIW zsh also exhibits this behavior.
      #
      # Reference:
      # https://www.vidarholen.net/contents/blog/?p=878
      # https://unix.stackexchange.com/questions/60459
      printf "\\e[7m\$\\e[0m%$((COLUMNS - 1))s\\r\\e[K"
    }

    PROMPT_COMMAND="__print_missing_lf;__vte_osc7;$PROMPT_COMMAND"
    ;;
esac

##########
#  Misc  #
##########
shopt -s checkjobs
shopt -s checkwinsize
shopt -s globstar
stty -ixoff -ixon # disable flow control

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# for macOS
if [[ "$OSTYPE" == darwin* ]]; then
  export CLICOLOR=1
  export COPYFILE_DISABLE=1
  alias ls='ls -F'
fi

###########
#  Theme  #
###########
if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
  return
fi

unset LS_COLORS # clear distro defaults

__prompt_dashboard_lite() {
  local exitcode="$?" # must come first

  PS1='\[\e]0;\w\a\]' # set terminal title

  if (( EUID == 0 || UID == 0 || EUID != UID )); then
    PS1+='\[\e[1;31m\]\u\[\e[0m\] in '
  fi
  PS1+='\[\e[1;34m\]\w\[\e[0m\]'
  if [[ -n "$SSH_CONNECTION" ]]; then
    PS1+=' at \[\e[1;33m\]\h\[\e[0m\]'
  fi

  if (( exitcode == 0 )); then
    PS1+='\n\[\e[1;32m\]\$\[\e[0m\] '
  else
    PS1+='\n\[\e[1;31m\]\$\[\e[0m\] '
  fi
}

# must come last
PROMPT_COMMAND="__prompt_dashboard_lite;$PROMPT_COMMAND"
