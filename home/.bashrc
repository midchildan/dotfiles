case $- in
  *i*) ;;
  *) return;;
esac

###########################
#  Environment Variables  #
###########################
export GEM_HOME="$(/usr/bin/ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"

PATH="~/.local/bin:$PATH"
PATH+=":$GEM_HOME/bin"
PATH+=":$(/usr/bin/python -c 'import site; print(site.getuserbase())')/bin"
PATH+=":$(/usr/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
PATH+=":$GOPATH/bin"
export PATH

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
alias peda='GDB_USE_GEF=1 GDB_USE_PEDA=0 GDB_USE_PWNDBG=0 gdb'
alias peda='GDB_USE_GEF=0 GDB_USE_PEDA=1 GDB_USE_PWNDBG=0 gdb'
alias pwndbg='GDB_USE_GEF=0 GDB_USE_PEDA=0 GDB_USE_PWNDBG=1 gdb'
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

###########
#  Theme  #
###########
if [[ -z "${debian_root:-}" ]] && [[ -r /etc/debian_chroot ]]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

if [[ $TERM == "dumb" ]]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
else
  command -v dircolors >/dev/null 2>&1; then
    if [[ -r ~/.dircolors ]]; then
      eval "$(dircolors -b ~/.dircolors)"
    else
      eval "$(dircolors -b)"
    fi
  fi

  prompt_color='\[\033[1m\]'
  prompt_login='${debian_chroot:+($debian_chroot)}\u'
  prompt_title='\[\e]0;${debian_chroot:+($debian_chroot)}\w\a\]'
  if [[ -n "$SSH_CONNECTION" ]]; then
    prompt_color='\[\033[1;32m\]'
    prompt_login+='@\h'
    prompt_title='\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h:\w\a\]'
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

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [[ "$SHELL" != *"zsh" ]] && grep -q zsh /etc/shells; then
  echo "[NOTICE] zsh is available on this system." >&2
fi
