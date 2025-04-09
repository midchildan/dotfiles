if [[ -f ~/.nix-profile/etc/profile.d/hm-session-vars.sh ]]; then
  source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

export LANG="en_US.UTF-8"
export EDITOR="nvim"
export PAGER="less"
export GOPATH=~/Documents/src/go
export -T LESS less ' '
export -T SYSTEMD_LESS systemd_less ' '

less=(
  --ignore-case
  --incsearch
  --long-prompt
  --RAW-CONTROL-CHARS
  --quit-if-one-screen
)

systemd_less=("${less[@]}" --chop-long-lines)

# whether to make use of powerline fonts
if [[ -n "$DISPLAY$WAYLAND_DISPLAY$SSH_CONNECTION$SSH_TTY" ]]; then
  export USE_POWERLINE=1
else
  export USE_POWERLINE=0
fi
