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

PATH="~/.local/bin:/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"
PATH+=":$GEM_HOME/bin"
PATH+=":$(/usr/local/bin/python2 -c 'import site; print(site.getuserbase())')/bin"
PATH+=":$(/usr/local/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
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

###########
#  Theme  #
###########
if [[ $TERM == "dumb" ]]; then
  PS1='\u@\h:\w\$ '
else
  prompt_color='\[\033[1m\]'
  prompt_login='\u'
  prompt_title=''
  if [[ -n "$SSH_CONNECTION" ]]; then
    prompt_color='\[\033[1;32m\]'
    prompt_login+='@\h'
    prompt_title='\[\e]0;\u@\h:\w\a\]'
  fi
  if [[ $EUID -eq 0 ]]; then
    prompt_color='\[\033[1;31m\]'
  fi
  PS1=$prompt_title$prompt_color$prompt_login
  PS1+='\[\033[0;1m\]:\[\033[34m\]\w\[\033[0;1m\]\$\[\033[0m\] '
  unset prompt_color prompt_login prompt_title
fi

##########
#  Misc  #
##########
shopt -s checkjobs
shopt -s checkwinsize
shopt -s globstar

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

if [[ "$SHELL" != *"zsh" ]] && grep -q zsh /etc/shells; then
  echo "[NOTICE] zsh is available on this system." >&2
fi
