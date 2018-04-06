fpath+=(~/.local/share/zsh/site-functions /usr/local/share/zsh-completions)
autoload -Uz add-zsh-hook
autoload -Uz is-at-least

###########################
#  Environment Variables  #
###########################
export CLICOLOR=1
export GEM_HOME="$(/usr/local/bin/ruby -e 'print Gem.user_dir')"
export GPG_TTY="$(tty)"
export USE_POWERLINE=0

typeset -U path
path=(
  ~/.local/bin
  /usr/local/opt/python/libexec/bin
  /usr/local/sbin
  $path
  ~/.cargo/bin
  "$GEM_HOME/bin"
  "$(python3 -c 'import site; print(site.getuserbase())')/bin"
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
autoload -Uz zmv
autoload -Uz cd.. fuck
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

# case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' recent-dirs-insert fallback
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' \
  command "ps -u `whoami` -o pid,user,comm -w -w"

# skip the slooow security checks (-C), it's pointless in a single-user setup
autoload -Uz compinit && compinit -C

#################
#  Keybindings  #
#################
autoload -Uz copy-earlier-word && zle -N copy-earlier-word
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
  '^B' copy-earlier-word \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^I' fzf-complete \
  '^J' self-insert \
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

local _mode _char
for _mode in visual viopp; do
  for _char in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $_mode $_char select-bracketed
  done
  for _char in {a,i}{\',\",\`}; do
    bindkey -M $_mode $_char select-quoted
  done
done

##########
#  Misc  #
##########
setopt interactive_comments
setopt long_list_jobs
setopt no_clobber
setopt no_flowcontrol
autoload -Uz select-word-style && select-word-style bash
autoload -Uz zrecompile && zrecompile -p -R ~/.zshrc -- -M ~/.zcompdump
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic
if is-at-least 5.2; then
  autoload -Uz bracketed-paste-url-magic && \
    zle -N bracketed-paste bracketed-paste-url-magic
fi

# Tell Apple Terminal the working directory
if [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]]; then
  __vte_urlencode() {
    # Use LC_CTYPE=C to process text byte-by-byte.
    local LC_CTYPE=C LC_ALL= _raw_url="$1" _safe_url="" _safe
    while [[ -n "$_raw_url" ]]; do
      _safe="${_raw_url%%[!a-zA-Z0-9/:_\.\-\!\'\(\)~]*}"
      _safe_url+="$_safe"
      _raw_url="${_raw_url#"$_safe"}"
      if [[ -n "$_raw_url" ]]; then
        _safe_url+="%$(([##16] #_raw_url))"
        _raw_url="${_raw_url#?}"
      fi
    done
    echo -E "$_safe_url"
  }

  __vte_osc7() {
    printf "\e]7;file://%s%s\a" "$HOST" "$(__vte_urlencode "$PWD")"
  }
  add-zsh-hook precmd __vte_osc7
  __vte_osc7
fi

###########
#  Theme  #
###########
setopt prompt_subst

[[ -z "$TERM_PROGRAM" ]] && USE_POWERLINE=0

if [[ "$TERM" == "dumb" ]]; then
  PROMPT="%n: %~%# "
  unset zle_bracketed_paste
  bindkey -v '^J' accept-line
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
  local _prompt="%(?::%F{red})%#%f" _login="%B%(!:%F{red}:)" _hname=""
  if [[ -n "$SSH_CONNECTION" ]]; then
    _login="%B%(!:%F{red}:%F{green})"
    _hname="@%m"
  fi

  local _begin= _end=
  if zstyle -T ':iterm2:osc' enable; then
    _begin=$'%{\e]133;D;%?\a\e]133;A\a%}'
    _end=$'%{\e]133;B\a%}'
  fi

  vcs_info
  if [[ -n "$vcs_info_msg_0_" ]]; then
    PROMPT="$_begin$_login$vcs_info_msg_0_"$'\n'"$_prompt%b $_end"
    RPROMPT="$vcs_info_msg_1_"
  else
    PROMPT="$_begin$_login%n$_hname%f: %F{blue}%~%f"$'\n'"$_prompt%b $_end"
    RPROMPT=""
  fi
}

__update_term() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;%m: %1~\a"
  else
    local title=""
    [[ "$TERM_PROGRAM" != "Apple_Terminal" ]] && title="%1~"
    print -Pn "\e]0;$title\a"
  fi

  if zstyle -T ':iterm2:osc' enable; then
    printf "\e]1337;RemoteHost=%s@%s\a\e]1337;CurrentDir=%s\a\e]133;C\a" \
      "$USER" "$HOST" "$PWD"
  fi
}

add-zsh-hook precmd __update_prompt
add-zsh-hook preexec __update_term

case "$TERM" in
  xterm-256color|screen-256color)
    __vi_cursor() {
      local _shape=6
      [[ "$ZLE_STATE" == *overwrite* ]] && _shape=4
      [[ "$KEYMAP" == vicmd ]] && _shape=2
      print -Pn "\e[$_shape q"
    }

    __reset_cursor() {
      print -Pn "\e[2 q"
    }

    zle -N zle-line-init __vi_cursor
    zle -N zle-keymap-select __vi_cursor
    add-zsh-hook preexec __reset_cursor
    ;;
esac

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
