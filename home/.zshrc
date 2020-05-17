fpath+=(~/.local/share/zsh/site-functions)
autoload -Uz add-zsh-hook
autoload -Uz is-at-least

[[ -d ~/.cache/zsh/completion ]] || mkdir -p ~/.cache/zsh/completion

###########################
#  Environment Variables  #
###########################
export GEM_HOME="$(ruby -e 'print Gem.user_dir')"
export GPG_TTY="$TTY"

typeset -U path
path=(
  ~/.local/bin
  $path
  ~/.cargo/bin
  "$GEM_HOME/bin"
  "$(python3 -c 'import site; print(site.getuserbase())')/bin"
  "$GOPATH/bin"
  ~/.emacs.d/bin
)

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
autoload -Uz br cud fuck
autoload -Uz fzf-sel fzf-run fzf-loop fzf-gen

#################
#  Directories  #
#################
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

autoload -Uz chpwd_recent_dirs cdr
chpwd_functions=(chpwd_recent_dirs)
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-file ~/.cache/zsh/cdhistory

#############
#  History  #
#############
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

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

() {
  setopt localoptions extended_glob
  autoload -Uz compinit

  zstyle ':completion:*' menu select
  zstyle ':completion:*' use-cache true
  zstyle ':completion:*' cache-path ~/.cache/zsh/completion
  zstyle ':completion:*' list-colors ''
  zstyle ':completion:*' recent-dirs-insert fallback
  # case-insensitive (all),partial-word and then substring completion
  zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

  zstyle ':completion:*:functions' ignored-patterns '(_*|prompt_*)'
  zstyle ':completion:*:manuals' separate-sections true
  zstyle ':completion:*:manuals.(^1*)' insert-sections true
  zstyle ':completion:*:*:kill:*:processes' list-colors \
    '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
  zstyle ':completion:*:*:*:*:processes' \
    command "ps -u $USER -o pid,user,comm -w -w"
  zstyle ':completion:*:*:*:users' ignored-patterns '_*'

  # update the completion cache only once a day
  if [[ -n ~/.cache/zsh/compdump(#qN.m+1) ]]; then
    # XXX: ignore compaudit warnings b/c it's pointless for most people
    compinit -u -d ~/.cache/zsh/compdump && touch ~/.cache/zsh/compdump
  else
    compinit -C -d ~/.cache/zsh/compdump # skip compaudit b/c it's slow
  fi

  compdef rcd=ssh
}

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
autoload -Uz vim-pipe && zle -N vim-pipe
autoload -Uz fzf-completion && zle -N fzf-completion
autoload -Uz fzf-cd-widget && zle -N fzf-cd-widget
autoload -Uz fzf-cdr-widget && zle -N fzf-cdr-widget
autoload -Uz fzf-file-widget && zle -N fzf-file-widget
autoload -Uz fzf-history-widget && zle -N fzf-history-widget
autoload -Uz fzf-snippet-expand && zle -N fzf-snippet-expand
autoload -Uz fzf-snippet-next && zle -N fzf-snippet-next
autoload -Uz toggle-leading-space && zle -N toggle-leading-space
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround
autoload -Uz vim-incarg \
  && zle -N vim-incarg \
  && zle -N vim-decarg vim-incarg \
  && zle -N sync-incarg vim-incarg \
  && zle -N sync-decarg vim-incarg

unalias run-help 2>/dev/null
autoload -Uz run-help run-help-git run-help-ip run-help-openssl run-help-sudo

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^B' copy-earlier-word \
  '^E' history-incremental-search-forward \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^I' fzf-completion \
  '^J' fzf-snippet-next \
  '^N' history-beginning-search-forward \
  '^O' fzf-cdr-widget \
  '^P' history-beginning-search-backward \
  '^T' toggle-leading-space \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^F' fzf-file-widget \
  '^X^J' fzf-snippet-expand \
  '^X^O' complete-from-help \
  '^X^R' fzf-history-widget \
  '^Y' history-incremental-search-backward \
  '^?' backward-delete-char
bindkey -ra 's'
bindkey -a \
  'gf' fzf-cd-widget \
  'g^A' sync-incarg \
  'g^X' sync-decarg \
  'sa' add-surround \
  'sd' delete-surround \
  'sr' change-surround \
  'K' run-help \
  '^A' vim-incarg \
  '^W' edit-command-line \
  '^X' vim-decarg \
  '!' vim-pipe
bindkey -M menuselect \
  '^B' backward-char \
  '^E' undo \
  '^F' forward-char \
  '^J' accept-and-menu-complete \
  '^N' down-line-or-history \
  '^P' up-line-or-history \
  '^X^F' accept-and-infer-next-history \
  '^X^X' vi-insert \
  '^Y' accept-line

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
    ;|
  eterm*|xterm-kitty)
    zstyle ':iterm2:osc' enable false
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
autoload -Uz zrecompile && \
  zrecompile -pq -R ~/.zshrc -- -M ~/.cache/zsh/compdump &!
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
if is-at-least 5.2; then
  autoload -Uz bracketed-paste-url-magic && \
    zle -N bracketed-paste bracketed-paste-url-magic
fi

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"
source /etc/zsh_command_not_found

###########
#  Theme  #
###########
if [[ "$TERM" == "dumb" ]]; then
  unsetopt zle prompt_cr prompt_subst
  add-zsh-hook -D precmd '*'
  add-zsh-hook -D preexec '*'
  PROMPT="%n: %~%# "
  return
fi

unset LS_COLORS # clear distro defaults

autoload -Uz promptinit && promptinit
prompt concise

# must be run last
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
