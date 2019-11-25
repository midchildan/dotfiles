;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))

;; key-bind
(global-set-key (kbd "C-j") 'forward-word)
(global-set-key (kbd "C-h") 'backward-word)
(global-set-key (kbd "C-l") 'kill-word)
(global-set-key (kbd "C-x C-a") 'recenter)
(global-set-key (kbd "C-q") 'scroll-down-command)
(global-set-key (kbd "C-*") 'goto-line)
(global-set-key (kbd "M-*") 'pop-tag-mark)
(global-set-key (kbd "C-z") 'flycheck-next-error)
(global-set-key (kbd "C-o") 'other-window)


;; move
(setq scroll-conservatively 1)
(setq scroll-margin 3)


;; display
(require 'linum)
(global-linum-mode 1)
(global-linum-mode) ;; show line number
(add-to-list 'default-frame-alist '(font . "ricty-12")) ;; font
(load-theme 'monokai t) ;; color
(require 'hiwin)
(hiwin-activate)
(set-face-background 'hiwin-face "gray20") ;; change inactive windows color
(setq default-tab-width 8)
(show-paren-mode t)
(which-function-mode t) ;; show function name of cursor
(global-hl-line-mode t) ;; highlight cursor line
(custom-set-faces
'(hl-line ((t (:background "color-236"))))
)
(menu-bar-mode -1)


;; edit
(setq-default indent-tabs-mode t)
(defun my-c-c++-mode-init ()
  (setq c-basic-offset 8)
  )
(add-hook 'c-mode-hook 'my-c-c++-mode-init)
(add-hook 'c++-mode-hook 'my-c-c++-mode-init)



;; misc
(setq ring-bell-function 'ignore)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
(let ((ls (member 'mode-line-buffer-identification 
                  mode-line-format)))
  (setcdr ls
    (cons '(:eval (concat " ("
            (abbreviate-file-name default-directory)
            ")"))
	  (cdr ls)))) ;; show current directory


