(show-paren-mode t)
;;(setq default-major-mode 'test-mode)
(setq text-mode-hook 'turn-on-auto-fill)




(global-set-key "\C-j" 'nil)
(global-set-key "\C-j" 'forward-word)
(global-set-key "\C-h" 'nil)
(global-set-key "\C-h" 'backward-word)
(global-set-key "\C-o" 'nil)
(global-set-key "\C-o" (lambda () (interactive) (other-window 1)))
(global-set-key "\C-l" 'nil)
(global-set-key "\C-l" 'kill-word)
(global-set-key "\C-x\C-a" 'nil)
(global-set-key "\C-x\C-a" 'recenter)
(global-set-key "\C-x\C-g" 'nil)
(global-set-key "\C-x\C-g" 'goto-line)
(global-set-key "\C-q" 'nil)
(global-set-key "\C-q" 'scroll-down-command)
(global-set-key "\M-*" 'nil)
(global-set-key "\M-*" 'pop-tag-mark)
;;(define-key global-map (kbd "C-q") 'flycheck-next-error)
;;(define-key global-map (kbd "C-z") 'flycheck-next-error)


;;(global-set-key "\C-m" 'nil)
;;(global-set-key "\C-m" 'set-mark-command)
;;(global-set-key "\C




(setq ring-bell-function 'ignore)

(defun all-indent ()
     (interactive)
     (mark-whole-buffer)
     (indent-region (region-beginning)(region-end))
     (point-undo))
(global-set-key (kbd  "\M-i") 'all-indent) 



;;(add-hook 'after-init-hook #'global-flycheck-mode)

(setq scroll-conservatively 1)

(require 'linum)
(global-linum-mode)
(setq-default indent-tabs-mode t)
(defun my-c-c++-mode-init ()
  (setq c-basic-offset 8)
  )
(add-hook 'c-mode-hook 'my-c-c++-mode-init)
(add-hook 'c++-mode-hook 'my-c-c++-mode-init)
