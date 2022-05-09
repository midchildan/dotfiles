if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

export COPYFILE_DISABLE=1
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LESS="iFMR"
export PAGER="less"
export GOPATH=~/Documents/src/go

# whether to make use of powerline fonts
if [[ -z "$USE_POWERLINE" ]]; then
  case "$TERM:$TERM_PROGRAM" in
    xterm-kitty:) USE_POWERLINE=1 ;; # kitty can use the powerline font directly
    *:iTerm.app) USE_POWERLINE=1 ;; # iTerm provides built-in powerline glyphs
    *) USE_POWERLINE=0 ;;
  esac
  export USE_POWERLINE
fi

if [[ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" && -f /etc/nix/darwin.sh ]]; then
  source /etc/nix/darwin.sh
fi
