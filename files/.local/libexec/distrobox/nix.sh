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
    if ! grep -q "^$dot_shell_path\$" /etc/shells; then
      echo "$dot_shell_path" | tee -a /etc/shells > /dev/null
    fi
    # shellcheck disable=SC2154
    usermod --shell "$dot_shell_path" "$container_user_name"
    break
  fi
done
