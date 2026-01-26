#{{{ Preamble

typeset -U fpath; fpath+=~/.local/share/zsh/site-functions
autoload -Uz add-zsh-hook is-at-least
zmodload -i zsh/parameter

if [[ ! ( -d ~/.cache/zsh/completion && -d ~/.local/state/zsh ) ]]; then
  mkdir -p ~/.cache/zsh/completion ~/.local/state/zsh
fi

#}}}
#{{{ Environment Variables

export CLICOLOR=1
export GPG_TTY="$TTY"

typeset -U path
path=(
  ~/.local/bin
  "${path[@]}"
  ~/.config/emacs/bin
)

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

#}}}
#{{{ Aliases & Functions

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if (( $+commands[/bin/ls] )); then
  alias ls='/bin/ls -F --color=auto'
else
  alias ls='ls -F --color=auto'
fi
alias ll='ls -lh'
alias la='ls -lAh'

alias qlook='qlmanage -p'
alias sudoedit='sudo -e'
alias ssh-fa='ssh-agent ssh -o AddKeysToAgent=confirm -o ForwardAgent=yes'
autoload -Uz zmv
autoload -Uz bd br

#}}}
#{{{ Directories

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

autoload -Uz chpwd_recent_dirs cdr
chpwd_functions=(chpwd_recent_dirs)
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-file ~/.local/state/zsh/cdhistory

#}}}
#{{{ History

HISTFILE=~/.local/state/zsh/history
HISTSIZE=100000
SAVEHIST=100000

setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

#}}}
#{{{ Completion

setopt always_to_end
setopt complete_in_word
setopt correct
setopt magic_equal_subst
setopt menu_complete
setopt list_packed
setopt no_list_beep
zmodload -i zsh/complist

if [[ -n "$NIX_PROFILES" ]]; then
  fpath+=(${(z)^NIX_PROFILES}/share/zsh/{site-functions,$ZSH_VERSION/functions,vendor-completions})
fi

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
  if [[ -n ~/.cache/zsh/compdump(#qN.m+0) ]]; then
    # ignore compaudit warnings because it's pointless on single user systems
    compinit -u -d ~/.cache/zsh/compdump && touch ~/.cache/zsh/compdump
  else
    compinit -C -d ~/.cache/zsh/compdump # skip compaudit because it's slow
  fi

  compdef rcd=ssh
}

# define a completion widget that parses --help output
zle -C complete-from-help complete-word _generic
zstyle ':completion:complete-from-help:*' completer _complete _gnu_generic

#}}}
#{{{ Editing & Keybindings

setopt interactive_comments

autoload -Uz copy-earlier-word && zle -N copy-earlier-word
autoload -Uz edit-command-line && zle -N edit-command-line
autoload -Uz insert-composed-char && zle -N insert-composed-char
autoload -Uz select-bracketed && zle -N select-bracketed
autoload -Uz select-quoted && zle -N select-quoted
autoload -Uz smart-insert-last-word && zle -N smart-insert-last-word
autoload -Uz toggle-leading-space && zle -N toggle-leading-space
autoload -Uz fzf-cdr-widget && zle -N fzf-cdr-widget
autoload -Uz fzf-cd-repo-widget && zle -N fzf-cd-repo-widget
autoload -Uz fzf-snippet-expand && zle -N fzf-snippet-expand
autoload -Uz fzf-snippet-next \
  && zle -N fzf-snippet-next \
  && zle -N fzf-snippet-accept fzf-snippet-next
autoload -Uz fzf-widgets \
  && zle -N fzf-menu-widget fzf-widgets \
  && zle -N fzf-completion fzf-widgets \
  && zle -N fzf-cd-widget fzf-widgets \
  && zle -N fzf-file-widget fzf-widgets \
  && zle -N fzf-history-widget fzf-widgets
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround
autoload -Uz vim-incarg \
  && zle -N vim-incarg \
  && zle -N vim-decarg vim-incarg \
  && zle -N vim-sync-incarg vim-incarg \
  && zle -N vim-sync-decarg vim-incarg

(( $+aliases[run-help] )) && unalias run-help
autoload -Uz run-help run-help-{git,openssl,sudo,gh,nix}

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^B' copy-earlier-word \
  '^E' history-incremental-search-forward \
  '^F' fzf-snippet-accept \
  '^Gu' split-undo \
  '^G^F' fzf-cd-widget \
  '^G^O' fzf-cdr-widget \
  '^G^P' fzf-cd-repo-widget \
  '^H' backward-delete-char \
  '^I' fzf-completion \
  '^J' fzf-snippet-next \
  '^K' insert-composed-char \
  '^N' history-beginning-search-forward \
  '^O' accept-line-and-down-history \
  '^P' history-beginning-search-backward \
  '^T' toggle-leading-space \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^F' fzf-file-widget \
  '^X^J' fzf-snippet-expand \
  '^X^L' fzf-history-widget \
  '^X^O' complete-from-help \
  '^X^U' fzf-menu-widget \
  '^Y' history-incremental-search-backward \
  '^?' backward-delete-char
bindkey -ra 's'
bindkey -a \
  'g^A' vim-sync-incarg \
  'g^X' vim-sync-decarg \
  'sa' add-surround \
  'sd' delete-surround \
  'sr' change-surround \
  'z=' spell-word \
  'K' run-help \
  '^A' vim-incarg \
  '^X' vim-decarg \
  '!' edit-command-line
# https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#Menu-selection
bindkey -M menuselect \
  '^B' backward-char \
  '^E' undo \
  '^F' forward-char \
  '^J' accept-and-menu-complete \
  '^N' down-line-or-history \
  '^O' accept-and-infer-next-history \
  '^P' up-line-or-history \
  '^X' vi-insert \
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

autoload -Uz select-word-style && select-word-style bash
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

if is-at-least 5.2; then
  autoload -Uz bracketed-paste-url-magic && \
    zle -N bracketed-paste bracketed-paste-url-magic
fi

#}}}
#{{{ Terminal Support

setopt no_flowcontrol

_zshrc::set_title() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;%m: %1~\a"
  else
    local title='%1~'
    [[ "$TERM_PROGRAM" == "Apple_Terminal" ]] && title=""
    print -Pn "\e]0;$title\a"
  fi
}

_zshrc::report_cwd() {
  setopt localoptions extended_glob no_multibyte
  local match mbegin mend
  local pattern="[^A-Za-z0-9_.!~*\'\(\)-\/]"
  local unsafepwd; unsafepwd=( ${(s::)PWD} )

  # url encode
  printf "\e]7;file://%s%s\a" \
    "$HOST" ${(j::)unsafepwd/(#b)($~pattern)/%${(l:2::0:)$(([##16]#match))}}

  # report current username to iTerm
  printf "\e]1337;RemoteHost=%s@\a" "$USER"
}

_zshrc::vi_cursor() {
  local shape=6
  [[ "$ZLE_STATE" == *overwrite* ]] && shape=4
  [[ "$KEYMAP" == vicmd ]] && shape=2
  print -Pn "\e[$shape q"
}

_zshrc::reset_cursor() {
  print -Pn "\e[2 q"
}

case "$TERM" in
  xterm*|screen*|tmux*)
    zle -N zle-line-init _zshrc::vi_cursor
    zle -N zle-keymap-select _zshrc::vi_cursor
    add-zsh-hook preexec _zshrc::reset_cursor
    add-zsh-hook precmd _zshrc::set_title
    ;| # fallthrough
  xterm*)
    add-zsh-hook precmd _zshrc::report_cwd
    ;| # fallthrough
  eterm*|xterm-kitty)
    zstyle ':dotfiles:prompt:*' enable-semantic-markers false
    ;;
esac

if [[ -n "$INSIDE_EMACS" ]]; then
  export EDITOR='emacsclient'

  # some keys are near impossible to send when using any of the emacs terminal
  # emulators, making customized keybindings infeasible
  bindkey -d # delete all custom keybindings
  bindkey -e
  bindkey -e \
    '^I' fzf-completion \
    '^N' history-beginning-search-forward \
    '^P' history-beginning-search-backward
fi

#}}}
#{{{ Misc

setopt long_list_jobs
setopt no_clobber
autoload -Uz zrecompile && \
  zrecompile -pq ~/.cache/zsh/compdump &!

#}}}
#{{{ Theme

if [[ "$TERM" == "dumb" ]]; then
  unsetopt zle prompt_cr prompt_subst
  unset CLICOLOR
  add-zsh-hook -D precmd '*'
  add-zsh-hook -D preexec '*'
  PROMPT="%n: %~%# "
  return
fi

unset LS_COLORS # clear distro defaults

autoload -Uz promptinit && promptinit
prompt dashboard
zstyle ':vcs_info:*' enable git

# must be run last
source ~/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_HIGHLIGHTERS+=(brackets)
ZSH_HIGHLIGHT_STYLES[comment]='fg=8,bold' # 8 = bright black

#}}}
# vim:set foldmethod=marker:
