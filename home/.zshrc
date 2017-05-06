fpath+=(~/.local/share/zsh/site-functions)
autoload -Uz add-zsh-hook

###########################
#  Environment Variables  #
###########################
export GEM_HOME="$(/usr/bin/ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"

typeset -U path
path=(
  "$HOME/.local/bin"
  $path
  "$GEM_HOME/bin"
  "$(/usr/bin/python -c 'import site; print(site.getuserbase())')/bin"
  "$(/usr/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
  "$GOPATH/bin"
)

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
alias peda='GDB_USE_PEDA=1 GDB_USE_PWNDBG=0 gdb'
alias pwndbg='GDB_USE_PEDA=0 GDB_USE_PWNDBG=1 gdb'
alias xmonad-replace='nohup xmonad --replace &> /dev/null &'
autoload -Uz edit-command-line
autoload -Uz run-help run-help-git run-help-openssl run-help-sudo
autoload -Uz zmv

#################
#  Directories  #
#################
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

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
setopt list_packed
zmodload -i zsh/complist

# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u `whoami` -o pid,user,comm -w -w"

autoload -Uz compinit && compinit -i

#################
#  Keybindings  #
#################
autoload -Uz smart-insert-last-word && zle -N smart-insert-last-word
autoload -Uz incarg && zle -N incarg
autoload -Uz decarg && zle -N decarg
autoload -Uz fzf-complete && zle -N fzf-complete
autoload -Uz fzf-cd-widget && zle -N fzf-cd-widget
autoload -Uz fzf-file-widget && zle -N fzf-file-widget
autoload -Uz fzf-history-widget && zle -N fzf-history-widget
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^I' fzf-complete \
  '^N' history-beginning-search-forward \
  '^O' fzf-cd-widget \
  '^P' history-beginning-search-backward \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^F' fzf-file-widget \
  '^X^R' fzf-history-widget \
  '^?' backward-delete-char
bindkey -a \
  'cs' change-surround \
  'ds' delete-surround \
  'ys' add-surround \
  'K' run-help \
  '^A' incarg \
  '^X' decarg \
  '\\/' history-incremental-pattern-search-backward \
  '\\?' history-incremental-pattern-search-forward
bindkey -M visual 'S' add-surround
bindkey -M menuselect \
  '^B' backward-char \
  '^F' forward-char \
  '^J' accept-and-menu-complete \
  '^N' down-line-or-history \
  '^P' up-line-or-history \
  '^X^I' vi-insert \
  '^X^F' accept-and-infer-next-history \
  '^?' undo

##########
#  Misc  #
##########
setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz select-word-style && select-word-style bash
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

command -v lesspipe >/dev/null 2>&1 && eval "$(SHELL=/bin/sh lesspipe)"
source /etc/zsh_command_not_found

###########
#  Theme  #
###########
setopt prompt_subst

if [[ "$TERM" == "dumb" ]]; then
  PROMPT="%n: %~%# "
  unset zle_bracketed_paste
else
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' actionformats \
    '%b@%s%f: %F{blue}%r/%S%f' '[%F{red}%a%f]%c%u'
  zstyle ':vcs_info:*' formats \
    '%b@%s%f: %F{blue}%r/%S%f' '%c%u'
  zstyle ':vcs_info:*' stagedstr "[%B%F{yellow}staged%f%b]"
  zstyle ':vcs_info:*' unstagedstr "[%B%F{red}unstaged%f%b]"
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' enable git

  update_prompt() {
    prompt_prompt="%(?::%F{red})%#%f"
    prompt_login="%B%(!:%F{red}:)"
    prompt_hname=""
    if [[ -n "$SSH_CONNECTION" ]]; then
      prompt_login="%B%(!:%F{red}:%F{green})"
      prompt_hname="@%m"
    fi

    vcs_info
    if [[ -n "$vcs_info_msg_0_" ]]; then
      PROMPT=$'$prompt_login$vcs_info_msg_0_\n$prompt_prompt%b '
      RPROMPT="$vcs_info_msg_1_"
    else
      PROMPT=$'$prompt_login%n$prompt_hname%f: %F{blue}%~%f\n$prompt_prompt%b '
      RPROMPT=""
    fi
  }

  update_title() {
    if [[ -n "$SSH_CONNECTION" ]]; then
      print -Pn "\e]0;%m: %1~\a"
    else
      print -Pn "\e]0;%1~\a"
    fi
  }

  add-zsh-hook precmd update_prompt
  add-zsh-hook preexec update_title

  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
fi
