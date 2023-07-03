#!/usr/bin/env sh

case "$1" in
  preinit)
    dot_shell=''

    case "$(realpath "$SHELL" 2> /dev/null || :)" in
      /nix/store/*|/gnu/store/*) ;;
      *) return ;;
    esac

    # Backup SHELL because distrobox changes it.
    dot_shell="$SHELL"

    # Try to prevent distrobox from installing an another shell. Doesn't work
    # if bash is missing from the container image.
    SHELL=''

    ;;

  init)
    if [ -d /run/host/etc/nix ]; then
      mount_bind /run/host/etc/nix /etc/nix ro
    fi

    if [ -z "$dot_shell" ] || [ "$SHELL" = "$dot_shell" ]; then
      return
    fi

    if [ -x "$dot_shell" ]; then
      # Restore SHELL.
      SHELL="$dot_shell"

      if ! grep -q "^$dot_shell\$" /etc/shells; then
        echo "$dot_shell" | tee -a /etc/shells > /dev/null
      fi

      # shellcheck disable=SC2154
      usermod --shell "$dot_shell" "$container_user_name"
    fi
    ;;

  *)
    printf '[ERROR] nix.sh: unknown script argument: %s' "$1"
    return 1
    ;;
esac
