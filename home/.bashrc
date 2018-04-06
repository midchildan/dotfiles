case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export CLICOLOR=1
export GEM_HOME="$(/usr/bin/ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"
export USE_POWERLINE=0

PATH="$HOME/.local/bin:/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"
PATH+=":$HOME/.cargo/bin"
PATH+=":$GEM_HOME/bin"
PATH+=":$(python3 -c 'import site; print(site.getuserbase())')/bin"
PATH+=":$GOPATH/bin"
export PATH

###########################
#  Aliases and Functions  #
###########################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F'
alias ll='ls -lh'
alias la='ls -lAh'
alias qlook='qlmanage -p'
alias sudoedit='sudo -e'

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
shopt -s checkjobs 2>/dev/null
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
stty -ixoff -ixon # disable flow control

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

source ~/.local/opt/fzftools/fzftools.bash

if [[ "$SHELL" != *"zsh" ]] && grep -q zsh /etc/shells; then
  echo "[NOTICE] zsh is available on this system." >&2
fi

###########
#  Theme  #
###########
[[ -z "$TERM_PROGRAM" ]] && USE_POWERLINE=0

if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
  return
fi

__prompt_color='\[\033[1m\]'
__prompt_login='\u'
__prompt_title=''
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
