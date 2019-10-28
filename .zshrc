autoload -Uz add-zsh-hook
autoload -Uz is-at-least

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
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
autoload -Uz zmv
command -v hub > /dev/null 2>&1 && alias git='hub'

[[ -f "$DOTDIR/.tmux.conf" ]] && alias tmux="tmux -f '$DOTDIR/.tmux.conf'"

#################
#  Directories  #
#################
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

################
#  Completion  #
################
setopt always_to_end
setopt complete_in_word
setopt correct
setopt magic_equal_subst
setopt menu_complete
setopt list_packed
zmodload -i zsh/complist

# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' recent-dirs-insert fallback
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.*' insert-sections true
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u `whoami` -o pid,user,comm -w -w"

# XXX: may be slow since caching is disabled
autoload -Uz compinit && compinit

# define a completion widget that parses --help output
zle -C complete-from-help complete-word _generic
zstyle ':completion:complete-from-help:*' completer _complete _gnu_generic

#################
#  Keybindings  #
#################
autoload -Uz copy-earlier-word && zle -N copy-earlier-word
autoload -Uz edit-command-line && zle -N edit-command-line
autoload -Uz select-bracketed && zle -N select-bracketed
autoload -Uz select-quoted && zle -N select-quoted
autoload -Uz smart-insert-last-word && zle -N smart-insert-last-word
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround

unalias run-help 2>/dev/null
autoload -Uz run-help run-help-git run-help-ip run-help-openssl run-help-sudo

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^B' copy-earlier-word \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^N' history-beginning-search-forward \
  '^P' history-beginning-search-backward \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^O' complete-from-help \
  '^?' backward-delete-char
bindkey -ra 's'
bindkey -a \
  'sa' add-surround \
  'sd' delete-surround \
  'sr' change-surround \
  'K' run-help \
  '^W' edit-command-line
bindkey -M menuselect \
  '^B' backward-char \
  '^F' forward-char \
  '^J' accept-and-menu-complete \
  '^N' down-line-or-history \
  '^P' up-line-or-history \
  '^U' undo \
  '^X^F' accept-and-infer-next-history \
  '^X^X' vi-insert

() {
  local mode key
  for mode in visual viopp; do
    for key in {a,i}${(s..)^:-'()[]{}<>bB'}; do
      bindkey -M $mode $key select-bracketed
    done
    for key in {a,i}{\',\",\`}; do
      bindkey -M $mode $key select-quoted
    done
  done
}

######################
#  Terminal Support  #
######################
__term_support() {
  # set title
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;%m: %1~\a"
  else
    print -Pn "\e]0;%1~\a"
  fi

  # report working directory
  () {
    setopt localoptions extended_glob no_multibyte
    local match mbegin mend
    local pattern="[^A-Za-z0-9_.!~*\'\(\)-\/]"
    local unsafepwd; unsafepwd=( ${(s::)PWD} )

    # url encode
    printf "\e]7;file://%s%s\a" \
      "$HOST" ${(j::)unsafepwd/(#b)($~pattern)/%${(l:2::0:)$(([##16]#match))}}
  }

  # report current username to iTerm
  if zstyle -T ':iterm2:osc' enable; then
    printf "\e]1337;RemoteHost=%s@\a" "$USER"
  fi
}

__vi_cursor() {
  local shape=6
  [[ "$ZLE_STATE" == *overwrite* ]] && shape=4
  [[ "$KEYMAP" == vicmd ]] && shape=2
  print -Pn "\e[$shape q"
}

__reset_cursor() {
  print -Pn "\e[2 q"
}

case "$TERM" in
  xterm*|screen*|tmux*)
    zle -N zle-line-init __vi_cursor
    zle -N zle-keymap-select __vi_cursor
    add-zsh-hook preexec __reset_cursor
    add-zsh-hook precmd __term_support
    ;;
esac

##########
#  Misc  #
##########
setopt interactive_comments
setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz select-word-style && select-word-style bash
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
if is-at-least 5.2; then
  autoload -Uz bracketed-paste-url-magic && \
    zle -N bracketed-paste bracketed-paste-url-magic
fi

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"

###########
#  Theme  #
###########
if [[ "$TERM" == "dumb" ]]; then
  PROMPT="%n: %~%# "
  unset zle_bracketed_paste
  bindkey -v '^J' accept-line
  return
fi

unset LS_COLORS # clear distro defaults

PROMPT='%B%(!:%F{red}:%F{green})%n@%m%f: %F{blue}%~%f'$'\n''%(?::%F{red})%#%f%b '