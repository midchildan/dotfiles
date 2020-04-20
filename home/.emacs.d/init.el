(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("ELPA" . "http://tromey.com/elpa/") t)

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
;; (setq package-archives
;;       '(("gnu" . "http://elpa.gnu.org/packages/")
;;         ("melpa" . "http://melpa.org/packages/")
;;         ("org" . "http://orgmode.org/elpa/")))

;; key-bind
(global-set-key (kbd "C-j") 'forward-word)
(global-set-key (kbd "C-h") 'backward-word)
(global-set-key (kbd "C-l") 'kill-word)
(global-set-key (kbd "C-x C-a") 'recenter)
(global-set-key (kbd "C-q") 'scroll-down-command)
(global-set-key (kbd "C-x C-g") 'goto-line)
(global-set-key (kbd "M-*") 'pop-tag-mark)
(global-set-key (kbd "C-z") 'flycheck-next-error)
(global-set-key (kbd "C-o") 'other-window)

;; scroll
(defun gcm-scroll-down ()
  (interactive)
  (scroll-up 1))
(defun gcm-scroll-up ()
  (interactive)
  (scroll-down 1))
(global-set-key (kbd "M-z") 'gcm-scroll-up)
(global-set-key (kbd "C-z") 'gcm-scroll-down)

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
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(hl-line ((t (:background "color-236")))))
(menu-bar-mode -1)


;; edit
;;(global-flycheck-mode t)

;; c, cpp mode
(setq-default indent-tabs-mode t)
(defun my-c-c++-mode-init ()
  (setq c-basic-offset 8)
  )
(add-hook 'c-mode-hook 'my-c-c++-mode-init)
(add-hook 'c++-mode-hook 'my-c-c++-mode-init)
(add-hook 'c-mode-hook 'rainbow-delimiters-mode)
;; (add-hook 'c-mode-hook flycheck-mode)
;; (add-hook 'c++-mode-hook flycheck-mode)

;; auto complete
(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)
;;(global-ac-complete-mode-map "\M-TAB" 'ac-next)
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)
(with-eval-after-load 'company
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous))

;; Rust mode
(require 'rust-mode)
(add-hook 'rust-mode-hook (lambda ()
                            (racer-mode)))
(add-hook 'rust-mode-hook (lambda() (add-hook 'before-save-hook 'rust-format-buffer)))
(add-hook 'rust-mode-hook 'rainbow-delimiters-mode)

(add-to-list 'exec-path(expand-file-name "~/.cargo/bin/"))
(add-hook 'racer-mode-hook (lambda ()
                             (company-mode)
                             ;;; この辺の設定はお好みで
                             (set (make-variable-buffer-local 'company-idle-delay) 0.1)
                             (set (make-variable-buffer-local 'company-minimum-prefix-length) 0)))


;; Eldoc mode
;; (require 'eldoc)
(global-eldoc-mode -1)
;; ;;(require 'eldoc-extension)
;; ;;(add-hook 'racer-mode-hook 'turn-on-eldoc-mode)
;; (add-hook 'c-mode-hook 'c-turn-on-eldoc-mode)
;; (add-hook 'c++-mode-hook 'c-turn-on-eldoc-mode)

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


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (company ac-racer ac-c-headers racer flycheck-pyflakes flycheck-pycheckers flycheck-cstyle auto-complete rainbow-delimiters rust-mode gnu-elpa-keyring-update helm monokai-theme hiwin))))




;; helm
;; (require 'helm-config)
;; (helm-mode 1)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files)
;; ;(global-set-key (kbd "C-c h") 'helm-command-prefix)


