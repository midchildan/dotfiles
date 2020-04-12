;; -*- lexical-binding: t; -*-
;;; $DOOMDIR/config.el

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.


;; UI
(setq doom-font (font-spec :family "monospace" :size 12)
      doom-theme 'doom-gruvbox
      display-line-numbers-type t
      frame-title-format '("%b")
      icon-title-format frame-title-format
      which-key-idle-delay 0.05)
(add-to-list 'default-frame-alist '(width . 132))
(add-to-list 'default-frame-alist '(height . 46))
(defun doom-dashboard-widget-banner nil)

;; Editing
(setq-default indent-tabs-mode nil
              tab-width 2)

;; Misc
(setq org-directory "~/Documents/org")

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:
