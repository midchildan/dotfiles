#{{{ Preamble

autoload -Uz add-zsh-hook is-at-least

#}}}
#{{{ Environment Variables

export EDITOR="vim"
export LANG="en_US.UTF-8"
export LESS="iMR"
export PAGER="less"
export SYSTEMD_LESS="iRSMK"
if [[ "$OSTYPE" == darwin* ]]; then
  export CLICOLOR=1
  export COPYFILE_DISABLE=1
fi

#}}}
#{{{ Aliases & Functions

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -F --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias ssh-fa='ssh-agent ssh -o AddKeysToAgent=confirm -o ForwardAgent=yes'
autoload -Uz zmv

::tmux() {
  local baseurl confdir="${DOTROOT:-$HOME}"
  zstyle -s ':dotfiles' baseurl baseurl
  if [[ -z "$_TMUXVER" && -f "$confdir/.tmux.conf" && "$1" != "current" ]]; then
    if [[ -n "$baseurl" ]]; then
      curl -sSfL "$baseurl/patches/tmux-$1.patch" | patch -d "$confdir" -p1 \
        && _TMUXVER="$1"
    else
      echo "[WARN] baseurl not set" >&2
    fi
  fi
  command tmux -f "$confdir/.tmux.conf" "${@:2}"
}

tmux-2.6() { ::tmux 2.6 "$@"; }
tmux-2.8() { ::tmux 2.8 "$@"; }
tmux-3.1() { ::tmux 3.1 "$@"; }
tmux-3.0() { ::tmux current "$@"; }
tmux() { ::tmux current "$@"; }

if ! command -v neofetch >/dev/null 2>&1; then
  neofetch() {
    curl -sSfL "https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch" \
      | bash -s -- --no_config "$@"
  }
fi

#}}}
#{{{ Directories

setopt auto_name_dirs
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_minus

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

() {
  setopt localoptions extended_glob
  autoload -Uz compinit

  zstyle ':completion:*' menu select
  zstyle ':completion:*' use-cache false
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

  # NOTE: may be slow since caching is disabled
  autoload -Uz compinit && compinit -D
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
autoload -Uz incarg \
  && zle -N vim-incarg incarg \
  && zle -N vim-decarg incarg \
  && zle -N vim-sync-incarg incarg \
  && zle -N vim-sync-decarg incarg
autoload -Uz surround \
  && zle -N delete-surround surround \
  && zle -N add-surround surround \
  && zle -N change-surround surround

(( $+aliases[run-help] )) && unalias run-help
autoload -Uz run-help run-help-{git,ip,openssl,sudo,gh,nix}

bindkey -v
bindkey -rv '^[,' '^[/' '^[~'
bindkey -v \
  '^A' smart-insert-last-word \
  '^B' copy-earlier-word \
  '^E' history-incremental-search-forward \
  '^Gu' split-undo \
  '^H' backward-delete-char \
  '^K' insert-composed-char \
  '^N' history-beginning-search-forward \
  '^O' accept-line-and-down-history \
  '^P' history-beginning-search-backward \
  '^U' backward-kill-line \
  '^W' backward-kill-word \
  '^X^O' complete-from-help \
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

if bindkey -l viopp &> /dev/null; then () {
  local mode key
  for mode in visual viopp; do
    for key in {a,i}${(s..)^:-'()[]{}<>bB'}; do
      bindkey -M $mode $key select-bracketed
    done
    for key in {a,i}{\',\",\`}; do
      bindkey -M $mode $key select-quoted
    done
  done
}; fi

autoload -Uz select-word-style && select-word-style bash
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

if is-at-least 5.2; then
  autoload -Uz bracketed-paste-url-magic && \
    zle -N bracketed-paste bracketed-paste-url-magic
fi

#}}}
#{{{ Terminal Support

setopt no_flowcontrol

__set_title() {
  if [[ -n "$SSH_CONNECTION" ]]; then
    print -Pn "\e]0;%m: %1~\a"
  else
    print -Pn "\e]0;%1~\a"
  fi
}

__report_cwd() {
  setopt localoptions extended_glob no_multibyte
  local match mbegin mend
  local pattern="[^A-Za-z0-9_.!~*\'\(\)-\/]"
  local unsafepwd; unsafepwd=( ${(s::)PWD} )

  # url encode
  printf "\e]7;file://%s%s\a" \
    "$HOST" ${(j::)unsafepwd/(#b)($~pattern)/%${(l:2::0:)$(([##16]#match))}}

  # report current username to iTerm
  if zstyle -T ':dotfiles:iterm2:osc' enable; then
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
    add-zsh-hook precmd __set_title
    ;| # fallthrough
  xterm*)
    add-zsh-hook precmd __report_cwd
    ;| # fallthrough
  eterm*|xterm-kitty)
    zstyle ':dotfiles:iterm2:osc' enable false
    ;;
esac

if [[ -n "$INSIDE_EMACS" ]]; then
  export EDITOR='emacsclient'

  # some keys are near impossible to send when using any of the emacs terminal
  # emulators, making customized keybindings infeasible
  bindkey -d # delete all custom keybindings
  bindkey -e
  bindkey -e \
    '^N' history-beginning-search-forward \
    '^P' history-beginning-search-backward
fi

#}}}
#{{{ Misc

setopt long_list_jobs
setopt no_clobber

zstyle ':dotfiles' baseurl 'https://www.midchildan.org/dotfiles'

#}}}
#{{{ Theme

if [[ "$TERM" == "dumb" ]]; then
  unsetopt zle prompt_cr prompt_subst
  add-zsh-hook -D precmd '*'
  add-zsh-hook -D preexec '*'
  PROMPT="%n: %~%# "
  return
fi

unset LS_COLORS # clear distro defaults

::prompt() {
  local baseurl
  zstyle -s ':dotfiles' baseurl baseurl
  if [[ -n "$baseurl" ]]; then
    source <(curl -sSfL "$baseurl/extras/prompt_${1}_setup")
  else
    echo "[WARN] baseurl not set" >&2
  fi
}

prompt_concise_setup() { ::prompt concise; }
prompt_dashboard_setup() { ::prompt dashboard; }
prompt_portable_setup() { # stripped down version of the "dashboard" theme
  PROMPT='%(!:%B%F{red}%n%f%b in :)%B%F{blue}%~%f%b at %B%F{yellow}%m%f%b'$'\n'
  PROMPT+='%B%(?:%F{green}:%F{red})>%f%b '
}

autoload -Uz promptinit && promptinit
prompt_themes+=(concise dashboard portable) # XXX: register prompts not in fpath
prompt portable

#}}}
# vim:set foldmethod=marker:
