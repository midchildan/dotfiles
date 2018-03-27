fpath+=(~/.local/share/zsh/site-functions)
autoload -Uz add-zsh-hook

###########################
#  Environment Variables  #
###########################
export GPG_TTY="$(tty)"
export USE_POWERLINE=0

typeset -U path
path=(
  ~/.local/bin
  $path
  "$GOPATH/bin"
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
alias xmonad-replace='nohup xmonad --replace &> /dev/null &'
autoload -Uz zmv
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

#############
#  History  #
#############
if [[ -z "$HISTFILE" ]]; then
  HISTFILE=~/.zsh_history
fi
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

# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' recent-dirs-insert fallback
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u `whoami` -o pid,user,comm -w -w"

# skip the slooow security checks (-C), it's pointless in a single-user setup
autoload -Uz compinit && compinit -C

#################
#  Keybindings  #
#################
autoload -Uz edit-command-line && zle -N edit-command-line
autoload -Uz select-bracketed && zle -N select-bracketed
autoload -Uz select-quoted && zle -N select-quoted
autoload -Uz smart-insert-last-word && zle -N smart-insert-last-word
autoload -Uz run-help run-help-git run-help-openssl run-help-sudo
autoload -Uz fzf-complete && zle -N fzf-complete
autoload -Uz fzf-cd-widget && zle -N fzf-cd-widget
autoload -Uz fzf-cdr-widget && zle -N fzf-cdr-widget
autoload -Uz fzf-file-widget && zle -N fzf-file-widget
autoload -Uz fzf-history-widget && zle -N fzf-history-widget
autoload -Uz fzf-snippet-expand && zle -N fzf-snippet-expand
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround
autoload -Uz vim-incarg \
  && zle -N vim-incarg \
  && zle -N vim-decarg vim-incarg

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^I' fzf-complete \
  '^N' history-beginning-search-forward \
  '^O' fzf-cdr-widget \
  '^P' history-beginning-search-backward \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^F' fzf-file-widget \
  '^X^J' fzf-snippet-expand \
  '^X^R' fzf-history-widget \
  '^?' backward-delete-char
bindkey -ra 's'
bindkey -a \
  'gf' fzf-cd-widget \
  'sa' add-surround \
  'sd' delete-surround \
  'sr' change-surround \
  'K' run-help \
  '^A' vim-incarg \
  '^X' vim-decarg \
  '!' edit-command-line
bindkey -M menuselect \
  '^B' backward-char \
  '^F' forward-char \
  '^J' accept-and-menu-complete \
  '^N' down-line-or-history \
  '^P' up-line-or-history \
  '^X^F' accept-and-infer-next-history \
  '^X^X' vi-insert \
  '^?' undo
for m in visual viopp; do
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
done

##########
#  Misc  #
##########
setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz select-word-style && select-word-style bash
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
autoload -Uz zrecompile && zrecompile -p -R ~/.zshrc -- -M ~/.zcompdump

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"

###########
#  Theme  #
###########
setopt prompt_subst

[[ -z "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION" ]] && USE_POWERLINE=0

if [[ "$TERM" == "dumb" ]]; then
  PROMPT="%n: %~%# "
  unset zle_bracketed_paste
  return
fi

autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
  '%b@%s%f: %F{blue}%r/%S%f' '[%F{red}%a%f]%c%u'
zstyle ':vcs_info:*' formats \
  '%b@%s%f: %F{blue}%r/%S%f' '%c%u'
zstyle ':vcs_info:*' stagedstr "[%B%F{yellow}staged%f%b]"
zstyle ':vcs_info:*' unstagedstr "[%B%F{red}unstaged%f%b]"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

__update_prompt() {
  local prompt_prompt="%(?::%F{red})%#%f"
  local prompt_login="%B%(!:%F{red}:)"
  local prompt_hname=""
  if [[ -n "$SSH_CONNECTION" ]]; then
    prompt_login="%B%(!:%F{red}:%F{green})"
    prompt_hname="@%m"
  fi

  vcs_info
  if [[ -n "$vcs_info_msg_0_" ]]; then
    PROMPT="$prompt_login$vcs_info_msg_0_"$'\n'"$prompt_prompt%b "
    RPROMPT="$vcs_info_msg_1_"
  else
    PROMPT="$prompt_login%n$prompt_hname%f: %F{blue}%~%f"$'\n'"$prompt_prompt%b "
    RPROMPT=""
  fi
}

__update_title() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;%m: %1~\a"
  else
    print -Pn "\e]0;%1~\a"
  fi
}

add-zsh-hook precmd __update_prompt
add-zsh-hook preexec __update_title

case "$TERM" in
  xterm-256color|screen-256color)
    __vi_cursor() {
      local cursor_shape=6
      [[ "$ZLE_STATE" == *overwrite* ]] && cursor_shape=4
      [[ "$KEYMAP" == vicmd ]] && cursor_shape=2
      print -Pn "\e[$cursor_shape q"
    }

    __reset_cursor() {
      print -Pn "\e[2 q"
    }

    zle -N zle-line-init __vi_cursor
    zle -N zle-keymap-select __vi_cursor
    add-zsh-hook preexec __reset_cursor
    ;;
esac

source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
