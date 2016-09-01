autoload -Uz add-zsh-hook

###########################
#  Environment Variables  #
###########################
export GEM_HOME="$(/usr/bin/ruby -e 'print Gem.user_dir')"

typeset -U path
path=(
  "$HOME/.local/bin"
  $path
  "$GEM_HOME/bin"
  "$(/usr/bin/python -c 'import site; print(site.getuserbase())')/bin"
  "$(/usr/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
  "$GOPATH/bin"
)

###########################
#  Aliases and Functions  #
###########################
alias grep='grep --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
autoload -Uz edit-command-line
autoload -Uz run-help run-help-git run-help-openssl run-help-sudo
autoload -Uz zmv
autoload -Uz zsh_stats

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

#################
#  Keybindings  #
#################
bindkey -v
bindkey -v "^?" backward-delete-char
bindkey -a "K" run-help
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

##########
#  Misc  #
##########
setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

source /etc/zsh_command_not_found

###########
#  Theme  #
###########
setopt prompt_subst

if [[ "$TERM" == "dumb" ]]; then
  PROMPT="%n: %~%# "
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
fi
