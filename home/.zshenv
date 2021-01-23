export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LESS="iFMR"
export PAGER="less"
export SYSTEMD_LESS="iFRSMK"

export GOPATH=~/Documents/src/go

# whether to make use of powerline fonts
export USE_POWERLINE=1
[[ "$TERM" == "xterm-kitty" ]] && USE_POWERLINE=1
[[ -z "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION" ]] && USE_POWERLINE=0

if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
