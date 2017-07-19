fpath+=(~/.local/share/zsh/site-functions /usr/local/share/zsh-completions)
autoload -Uz add-zsh-hook

###########################
#  Environment Variables  #
###########################
export CLICOLOR=1
export GEM_HOME="$(/usr/local/bin/ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"

typeset -U path
path=(
  "$HOME/.local/bin"
  "/usr/local/opt/python/libexec/bin"
  "/usr/local/sbin"
  $path
  "$GEM_HOME/bin"
  "$(/usr/local/bin/python2 -c 'import site; print(site.getuserbase())')/bin"
  "$(/usr/local/bin/python3 -c 'import site; print(site.getuserbase())')/bin"
  "$GOPATH/bin"
)

###########################
#  Aliases and Functions  #
###########################
unalias run-help
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F'
alias ll='ls -lh'
alias la='ls -lAh'
alias qlook='qlmanage -p'
alias sudoedit='sudo -e'
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
  '^X' decarg
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

# Tell Apple Terminal the working directory
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]]; then
  update_terminal_cwd() {

    # Percent-encode the pathname.
    local URL_PATH=''
    {
      # Use LC_CTYPE=C to process text byte-by-byte.
      local i ch hexch LC_CTYPE=C LC_ALL=
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

    printf '\e]7;%s\a' "file://$HOST$URL_PATH"
  }
  add-zsh-hook precmd update_terminal_cwd
  update_terminal_cwd
fi

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

  update_title() {
    if [[ -n "$SSH_CONNECTION" ]]; then
      print -Pn "\e]0;%m: %1~\a"
    else
      local title=""
      [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && title="%1~"
      print -Pn "\e]0;$title\a"
    fi
  }

  add-zsh-hook precmd update_prompt
  add-zsh-hook preexec update_title

  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
fi
