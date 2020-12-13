##########################
#  Early Initialization  #
##########################

# Setup some environment variables before the interactivity check. This is the
# only place where you can place startup commands that will be picked up by
# non-interactive SSH sessions.
#
# https://www.gnu.org/software/bash/manual/bash.html#Invoked-by-remote-shell-daemon

export COPYFILE_DISABLE=1
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LESS="iFMR"
export PAGER="less"

export GOPATH=~/Documents/src/go

# whether to make use of powerline fonts
export USE_POWERLINE=0
case "$TERM:$TERM_PROGRAM" in
  xterm-kitty:) USE_POWERLINE=1 ;; # kitty can use the powerline font directly
  *:iTerm.app) USE_POWERLINE=1 ;; # iTerm provides built-in powerline glyphs
  *:) USE_POWERLINE=0 ;;
esac

if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

# skip the rest for non-interactive sessions
case $- in
  *i*) ;;
  *) return ;;
esac

###########################
#  Environment Variables  #
###########################
export CLICOLOR=1
export GPG_TTY="$(tty)"

export PATH="$(shopt -s nullglob; printf "%s:" \
  ~/.local/bin \
  "$PATH" \
  /usr/local/sbin \
  /usr/local/opt/python@3/libexec/bin \
  "$GOPATH/bin" \
  ~/.emacs.d/bin \
)"

command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

###########################
#  Aliases and Functions  #
###########################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='/bin/ls -F'
alias ll='ls -lh'
alias la='ls -lAh'
alias qlook='qlmanage -p'
alias sudoedit='sudo -e'
alias ssh-fa='ssh-agent ssh -o AddKeysToAgent=confirm -o ForwardAgent=yes'

#############
#  History  #
#############
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s cmdhist
shopt -s lithist
shopt -s histappend

######################
#  Terminal Support  #
######################
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
shopt -s checkjobs 2>/dev/null
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
stty -ixoff -ixon # disable flow control

if [ -f /usr/local/etc/bash_completion ]; then
  . /usr/local/etc/bash_completion
fi

source ~/.local/opt/fzftools/fzftools.bash

###########
#  Theme  #
###########
if [[ $TERM == "dumb" ]]; then
  unset CLICOLOR
  PS1='\u@\h:\w\$ '
  return
fi

unset LS_COLORS # clear distro defaults

__prompt_color='\[\e[1m\]'
__prompt_login='\u'
__prompt_title=''
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
