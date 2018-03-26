case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export GPG_TTY="$(tty)"
export USE_POWERLINE=0
export PATH="$HOME/.local/bin:$PATH:$GOPATH/bin"

source ~/.nix-profile/etc/profile.d/nix.sh

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

if [[ "$SHELL" != *"zsh" ]] && grep -q zsh /etc/shells; then
  echo "[NOTICE] zsh is available on this system." >&2
fi

###########
#  Theme  #
###########
[[ -z "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION" ]] && unset USE_POWERLINE

if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
  return
fi

if [[ -r ~/.dircolors ]]; then
  eval "$(dircolors -b ~/.dircolors)"
else
  eval "$(dircolors -b)"
fi

__prompt_color='\[\033[1m\]'
__prompt_login='\u'
__prompt_title='\[\e]0;\w\a\]'
if [[ -n "$SSH_CONNECTION" ]]; then
  __prompt_color='\[\033[1;32m\]'
  __prompt_login+='@\h'
  __prompt_title='\[\e]0;\u@\h:\w\a\]'
fi
if [[ $EUID -eq 0 ]]; then
  __prompt_color='\[\033[1;31m\]'
fi
PS1=$__prompt_title$__prompt_color$__prompt_login
PS1+='\[\033[0;1m\]:\[\033[34m\]\w\[\033[0;1m\]\$\[\033[0m\] '
unset __prompt_color __prompt_login __prompt_title
