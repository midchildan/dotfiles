case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export GPG_TTY="$(tty)"
export PATH="$HOME/.local/bin:$PATH:$GOPATH/bin"

###########################
#  Aliases and Functions  #
###########################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias xmonad-replace='nohup xmonad --replace &> /dev/null &'

#############
#  History  #
#############
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s cmdhist
shopt -s lithist
shopt -s histappend

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

source ~/.local/opt/fzftools/fzftools.bash

# Tell libvte terminals the working directory
if (( "${VTE_VERSION:-0}" >= 3405 )); then
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
fi

###########
#  Theme  #
###########
if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
  return
fi

if [[ -r ~/.dircolors ]]; then
  eval "$(dircolors -b ~/.dircolors)"
else
  eval "$(dircolors -b)"
fi

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
