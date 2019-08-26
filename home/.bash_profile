export EDITOR="vim"
export LANG="en_US.UTF-8"
export LESS="iMR"
export PAGER="less"
export SYSTEMD_LESS="iRSMK"

export GOPATH=~/Documents/src/go
export ANDROID_HOME=~/.local/opt/android-sdk

# whether to make use of powerline fonts
export USE_POWERLINE=0
[[ -z "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION" ]] && USE_POWERLINE=0

[[ -f ~/.bashrc ]] && . ~/.bashrc
