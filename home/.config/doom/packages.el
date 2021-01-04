;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.

;; See ~/.emacs.d/core/templates/packages.example.el for examples. (press 'gf'
;; on the filename)

(package! japanese-holidays)
(package! yankpad)

;; These packages attempt to build native C code at runtime. Prefer copies
;; installed by Nix if they exist to avoid having to make GCC globally
;; available.
(package! pdf-tools :built-in 'prefer)
