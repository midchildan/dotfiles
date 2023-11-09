# Prevents macOS's path_helper(8) from clobbering $PATH in nested shells by
# blocking execution of /etc/zprofile.
if [[ -o login ]]; then
  # This option is toggled back again in .zprofile to allow /etc/zshrc to run.
  unsetopt global_rcs
fi

if [[ -z "$__DOT_ZPROFILE_DONE" ]]; then
  # Let macOS's path_helper(8) setup the system shell exactly once.
  source /etc/zprofile
  if [[ -d /opt/homebrew ]]; then
    path=(/opt/homebrew/{,s}bin "${path[@]}")
  fi
  export __DOT_ZPROFILE_DONE=1
fi
if [[ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" && -f /etc/nix/darwin.sh ]]; then
  source /etc/nix/darwin.sh
fi
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
