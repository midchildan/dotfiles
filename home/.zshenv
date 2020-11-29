export COPYFILE_DISABLE=1
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LESS="iFMR"
export PAGER="less"

export GTK_PATH=/usr/local/lib/gtk-2.0
export GOPATH=~/Documents/src/go

# whether to make use of powerline fonts
export USE_POWERLINE=0
case "$TERM:$TERM_PROGRAM" in
  xterm-kitty:) USE_POWERLINE=1 ;; # kitty can use the powerline font directly
  *:iTerm.app) USE_POWERLINE=1 ;; # iTerm provides built-in powerline glyphs
  *:) USE_POWERLINE=0 ;;
esac

if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
