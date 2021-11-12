export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LESS="iFMR"
export PAGER="less"
export SYSTEMD_LESS="iFRSMK"

export GOPATH=~/Documents/src/go

# whether to make use of powerline fonts
if [[ -n "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION" ]]; then
  export USE_POWERLINE=1
else
  export USE_POWERLINE=0
fi

if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
