#!/usr/bin/env bash

main() {
  local branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" != "master" ]]; then
    echo "Warning: current branch not 'master'"
  fi

  read -p "Enter your name: " NAME
  read -p "Enter your email: " EMAIL
  read -p "Enter your GPG key id (leave empty if none): " GPGKEYID

  echo "Patching..."
  create_patch | git apply -

  echo "Registering remote 'upstream'..."
  git remote add upstream https://github.com/midchildan/dotfiles.git

  echo "Complete! You can commit the changes by running:"
  echo "  export GIT_AUTHOR_NAME=\"$NAME\""
  echo "  export GIT_COMMITTER_NAME=\"$NAME\""
  echo "  export EMAIL=\"$EMAIL\""
  echo "  git commit -am 'replace profile information'"
}

create_patch() {
cat <<EOF
diff --git a/home/.config/git/config b/home/.config/git/config
index bd3a4ff..d2fc75b 100644
--- a/home/.config/git/config
+++ b/home/.config/git/config
@@ -1,$((${#GPGKEYID} ? 7 : 15)) +1,$((${#GPGKEYID} ? 7 : 12)) @@
 [user]
-	name = midchildan
-	email = git@midchildan.org
-	signingkey = 0x186A1EDAC5C63F83
+	name = $NAME
+	email = $EMAIL
EOF

[[ -n "$GPGKEYID" ]] && cat <<EOF
+	signingkey = $GPGKEYID
EOF

cat <<EOF
 [push]
 	default = simple
 [merge]
EOF

[[ -z "$GPGKEYID" ]] && cat <<EOF
 	tool = vimdiff
 [rebase]
 	autosquash = true
-[commit]
-	gpgsign = true
 [alias]
 	exec = "!exec " # run a shell command from the top directory
 [merge "ours"]
EOF

cat <<EOF
diff --git a/home/.gnupg/gpg.conf b/home/.gnupg/gpg.conf
index 9c98bf6..7cfae77 100644
--- a/home/.gnupg/gpg.conf
+++ b/home/.gnupg/gpg.conf
@@ -1,5 +1,$((${#GPGKEYID} ? 5 : 3)) @@
-default-key FEF0AE2D544934825F0640AA186A1EDAC5C63F83
-
EOF

[[ -n "$GPGKEYID" ]] && cat <<EOF
+default-key $GPGKEYID
+
EOF

cat <<EOF
 ##############
 #  Behavior  #
 ##############
EOF
}

main
