autoload -Uz add-zsh-hook

## environment variables ------------------------
export CLICOLOR=1
export EDITOR="vim"
export GREP_OPTIONS="--color=auto"
export LANG="en_US.UTF-8"
export LESS="-R"
export PAGER="less"

export GEM_HOME="$(/usr/bin/ruby -e 'print Gem.user_dir')"
export GTK_PATH=/usr/local/lib/gtk-2.0
export GOPATH=~/Documents/devel/go
export ANDROID_HOME=~/.local/opt/android-sdk

typeset -U path
path=(
  "~/.local/bin"
  "/usr/local/sbin"
  $path
  "$GEM_HOME/bin"
  "$(/usr/local/bin/python -c 'import site; print(site.getuserbase())')/bin"
  "$(/usr/local/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
  "$GOPATH/bin"
)

## aliases and functions ------------------------
unalias run-help && autoload -Uz run-help
autoload -Uz run-help-git run-help-openssl run-help-sudo

alias ls='ls -F'
alias ll='ls -lh'
alias la='ls -lAh'
alias qlook='qlmanage -p'
alias sudoedit='sudo -e'
autoload -Uz zsh_stats
autoload -Uz trash
autoload -Uz man-preview
autoload -Uz loadenv

## directories ----------------------------------
setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

## history --------------------------------------
if [ -z $HISTFILE ]; then
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

## autocompletion -------------------------------
setopt no_menu_complete
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt no_auto_remove_slash
setopt list_packed
setopt correct
zmodload -i zsh/complist

# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u `whoami` -o pid,user,comm -w -w"

autoload -Uz compinit && compinit -i

## misc -----------------------------------------
# keybindings
bindkey -v
bindkey -v "^?" backward-delete-char
bindkey -a "K" run-help
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

## theme ----------------------------------------
setopt prompt_subst

autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
  '%b@%s: %F{blue}%r/%S%f' '[%F{red}%a%f]%c%u'
zstyle ':vcs_info:*' formats \
  '%b@%s: %F{blue}%r/%S%f' '%c%u'
zstyle ':vcs_info:*' stagedstr "[%B%F{yellow}staged%f%b]"
zstyle ':vcs_info:*' unstagedstr "[%B%F{red}unstaged%f%b]"
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git

update_prompt() {
  ret_status="%(?:%(!.%F{green}#.%%):%F{red}%#)%f"
  vcs_info
  if [[ -n $vcs_info_msg_0_ ]]; then
    PROMPT=$'%B$vcs_info_msg_0_\n$ret_status%b '
    RPROMPT="$vcs_info_msg_1_"
  else
    PROMPT=$'%B%n: %F{blue}%~%f\n$ret_status%b '
    RPROMPT=""
  fi
}
add-zsh-hook precmd update_prompt

## Apple Terminal -------------------------------
# Tell Apple Terminal the working directory
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]]; then
  update_terminal_cwd() {
    # Identify the directory using a "file:" scheme URL, including
    # the host name to disambiguate local vs. remote paths.

    # Percent-encode the pathname.
    local URL_PATH=''
    {
      # Use LANG=C to process text byte-by-byte.
      local i ch hexch LANG=C
      for ((i = 1; i <= ${#PWD}; ++i)); do
        ch="$PWD[i]"
        if [[ "$ch" =~ [/._~A-Za-z0-9-] ]]; then
          URL_PATH+="$ch"
        else
          hexch=$(printf "%02X" "'$ch")
          URL_PATH+="%$hexch"
        fi
      done
    }

    local PWD_URL="file://$HOST$URL_PATH"
    printf '\e]7;%s\a' "$PWD_URL"
  }
  add-zsh-hook precmd update_terminal_cwd
  update_terminal_cwd
fi

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
