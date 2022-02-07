;; -*- lexical-binding: t; -*-
;;; $DOOMDIR/init.el

;; This file controls what Doom modules are enabled and what order they load in.
;; Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find information about all of Doom's modules
;;      and what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c g k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c g d') on a module to browse its
;;      directory (for easy access to its source code).
;;
;;      If you prefer a  more succint summary of each module, also have a look
;;      at ~/.emacs.d/init.example.el (press 'gf' on the filename)

(doom! :input
       ;;japanese

       :completion
       (company +childframe)
       ivy

       :ui
       doom
       doom-dashboard
       fill-column
       hl-todo
       ;;hydra
       indent-guides
       modeline
       ophints
       (popup +defaults)
       treemacs
       ;;unicode
       vc-gutter
       ;;vi-tilde-fringe
       workspaces
       zen

       :editor
       (evil +everywhere)
       file-templates
       fold
       format
       multiple-cursors
       snippets

       :emacs
       dired
       electric
       undo
       vc

       :term
       eshell
       vterm

       :checkers
       syntax
       ;;spell
       ;;grammar

       :tools
       ;;debugger
       direnv
       docker
       editorconfig
       ;;ein
       (eval +overlay)
       ;;gist
       lookup
       ;;lsp
       magit
       ;;make
       pdf
       ;;rgb
       ;;tmux
       ;;upload

       :lang
       ;;assembly
       ;;cc
       data
       emacs-lisp
       ;;ess
       ;;go
       ;;(java +meghanada)
       ;;javascript
       json
       ;;latex
       ledger
       markdown
       nix
       (org +dragndrop +pomodoro +roam2)
       ;;python
       rest
       ;;rust
       sh
       ;;web
       yaml

       :app
       rss

       :config
       literate
       (default +bindings +smartparens))

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
