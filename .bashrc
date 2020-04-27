case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export EDITOR="vim"
export LANG="en_US.UTF-8"
export LESS="iMR"
export PAGER="less"
export SYSTEMD_LESS="iRSMK"

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

::tmux() {
  if [[ -z "$_TMUXVER" && -f "$DOTROOT/.tmux.conf" && "$1" != "current" ]]; then
    curl -sSfL "https://midchildan.org/dotfiles/patches/tmux-"$1".patch" \
      | patch -d "$DOTROOT" -p1 \
      && _TMUXVER="$1"
  fi
  command tmux -f "$DOTROOT/.tmux.conf" "${@:2}"
}

tmux-2.4() { ::tmux 2.4 "$@"; }
tmux-2.6() { ::tmux 2.6 "$@"; }
tmux-3.0() { ::tmux 3.0 "$@"; }
tmux-3.1() { ::tmux 3.1 "$@"; }
tmux() { ::tmux current "$@"; }

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

##########
#  Misc  #
##########
shopt -s checkjobs
shopt -s checkwinsize
shopt -s globstar
stty -ixoff -ixon # disable flow control

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Report the working directory
case "$TERM" in
  xterm*|screen*|tmux*)
    __vte_urlencode() {
      # Use LC_CTYPE=C to process text byte-by-byte.
      local LC_CTYPE=C LC_ALL= raw_url="$1" safe
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

    __vte_osc7() {
      printf "\e]7;file://%s%s\a" "${HOSTNAME:-}" "$(__vte_urlencode "$PWD")"
    }

    PROMPT_COMMAND="__vte_osc7;$PROMPT_COMMAND"
    ;;
esac

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

__prompt_color='\[\e[1m\]'
__prompt_login='\u'
__prompt_title='\[\e]0;\w\a\]'
if [[ -n "$SSH_CONNECTION" ]]; then
  __prompt_color='\[\e[1;32m\]'
  __prompt_login+='@\h'
  __prompt_title='\[\e]0;\u@\h:\w\a\]'
fi
if (( EUID == 0 )); then
  __prompt_color='\[\e[1;31m\]'
fi
PS1=$__prompt_title$__prompt_color$__prompt_login
PS1+='\[\e[0;1m\]:\[\e[34m\]\w\[\e[0;1m\]\$\[\e[0m\] '
unset __prompt_color __prompt_login __prompt_title
