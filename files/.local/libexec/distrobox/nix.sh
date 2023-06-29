#!/usr/bin/env sh

dot_shell_name="$(basename "$SHELL")"

dot_nix_profiles="
  $HOME/.nix-profile
  ${XDG_STATE_HOME:-$HOME/.state}/nix/profile
  /run/current-system/sw
"

for dot_profile_dir in $dot_nix_profiles; do
  dot_shell_path="$dot_profile_dir/bin/$dot_shell_name"

  if [ -x "$dot_shell_path" ]; then
    SHELL="$dot_shell_path"
    chsh -u "$USER" "$dot_shell_path"
    if ! grep -q "^$dot_shell_path\$" /etc/shells; then
      echo "$dot_shell_path" | tee -a /etc/shells > /dev/null
    fi
    break
  fi
done
