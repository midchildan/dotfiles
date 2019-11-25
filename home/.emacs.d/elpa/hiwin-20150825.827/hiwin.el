;;; hiwin.el --- Visible active window mode.
;;
;; Copyright (C) 2009 k.sugita
;;               2010 tomoya <tomoya.ton@gmail.com>
;;               2011 k.sugita <ksugita0510@gmail.com>
;;
;; Author: k.sugita
;; Keywords: faces, editing, emulating
;; Package-Version: 20150825.827
;; Version: 2.00
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Usage
;;
;; put followings your .emacs
;;   (require 'hiwin)
;;   (hiwin-activate)
;;   (set-face-background 'hiwin-face "gray80")
;;
;; if you invisible active window, type M-x hiwin-deactivate.

;;; Changes
;;
;; 2011-12-23 k.sugita
;; tails-marks.elを参考に以下の実装を見直し，修正
;; ・ウィンドウ分割したとき，あるいはウィンドウ移動したとき
;;   オーバーレイを再作成するように修正
;; ・読み込み専用バッファの背景色を変更する処理を削除
;; ・非アクティブウィンドウの配色をフェイスで設定
;; ・描画対象外バッファの設定は未実装
;; 
;; 2010-08-13 k.sugita
;; *Completions*表示時にMiniBufの表示が崩れるのを修正
;; 手動で画面リフレッシュできるようhiwin-refresh-winをinteractive化
;; 個人的な設定だったため，recenterのadviceを削除
;; 
;; 2010-07-04 k.sugita
;; ローカルで再スクラッチしたファイルに tomoya氏，masutaka氏の修正を反映
;; readonlyなアクティブwindowの背景色を設定できるように機能変更
;; 
;; 2010-06-07 tomoya
;; マイナーモード化
;; 
;; 2009-09-13 k.sugita
;; ブログで公開
;; http://ksugita.blog62.fc2.com/blog-entry-8.html

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Code:

;; hiwin-modeの実行状態．non-nilの場合，hiwin-modeは有効．
(defvar hiwin-visible-status nil)

;; 非アクティブウィンドウのオーバーレイ数．現在のウィンドウ数に等しい．
(defvar hiwin-overlay-count nil)

;; 再描画時のアクティブウィンドウ．
(defvar hiwin-active-window nil)

;; 非アクティブウィンドウに描画するオーバーレイの行数．
(defvar hiwin-overlay-lines 96)

;; 非アクティブウィンドウのオーバーレイ．
(defvar hiwin-overlays nil)

;; 常時アクティブにするバッファ名の正規表現
(defvar hiwin-always-active-buffer-name-regexp "^\\*helm")


;; 非アクティブウィンドウのオーバーレイ描画用のフェイス．
(defface hiwin-face
  '((t (:background "gray25")))
  "Face for inactive window.")


(defvar hiwin-server-flag nil)

(define-minor-mode hiwin-mode
  "Visible active window."
  :global t
  :lighter " hiwin"
  :group 'hiwin
  (if hiwin-visible-status (hiwin-deactivate) (hiwin-activate) )
  )      

(defun hiwin-create-ol ()
  (let (
        (hw-buf nil) ;; 作業用バッファ
        (hw-cnt 0)   ;; ループカウンタ
        )
    ;; オーバーレイ作成済みの場合はスキップ
    (unless hiwin-overlays
      (progn
        ;; 現在のウィンドウ数から作成するオーバーレイ数を決定
        (setq hiwin-overlay-count (count-windows))
        ;; 作業用バッファを作成
        (setq hw-buf (get-buffer-create " *hiwin-temp*"))
        ;; 指定個数のオーバーレイを作成
        (while (< hw-cnt hiwin-overlay-count)
          ;; オーバーレイを作成
          (setq hiwin-overlays (cons (make-overlay 1 1 hw-buf nil t) hiwin-overlays))
          ;; 作成したオーバレイにフェイスを設定
          (overlay-put (nth 0 hiwin-overlays) 'face 'hiwin-face)
          ;; 作成したオーバレイの EOFのフェイスを設定
          (overlay-put (nth 0 hiwin-overlays) 'after-string
                       (propertize (make-string hiwin-overlay-lines ?\n)
                                   'face 'hiwin-face))
          ;; カウンタアップ
          (setq hw-cnt (1+ hw-cnt))
          )
        ;; 作業用バッファを削除
        (kill-buffer hw-buf)
        ))
      ))

(defun hiwin-delete-ol ()
  (let (
        (hw-cnt 0) ;; ループカウンタ
        )
    ;; オーバーレイ未作成の場合はスキップ
    (if hiwin-overlays
        (progn
          ;; 指定個数のオーバーレイを削除
          (while (< hw-cnt hiwin-overlay-count)
            ;; オーバーレイを削除
            (delete-overlay (nth hw-cnt hiwin-overlays))
            ;; カウンタアップ
            (setq hw-cnt (1+ hw-cnt))
            )
          ;; 念のため初期化
          (setq hiwin-overlays nil)
          ))
    ))

(defun hiwin-draw-ol ()
  (interactive)
  ;; すべてのオーバーレイを削除
  (hiwin-delete-ol)
  ;; その後，新たにオーバーレイを作成
  (hiwin-create-ol)
  ;; 描画時にアクティブなウィンドウを記憶
  (setq hiwin-active-window (selected-window))
  (let (
        (hw-act-buf (current-buffer))  ;; アクティブ バッファ
        (hw-tgt-win nil)               ;; 処理対象ウィンドウ
        (hw-win-lst (window-list))     ;; ウィンドウリスト
        (hw-cnt 0)                     ;; ループカウンタ
        )
    (while hw-win-lst
      ;; 処理対象ウィンドウを取得
      (setq hw-tgt-win (car hw-win-lst))
      ;; 取得したウィンドウをウィンドウリストから削除
      (setq hw-win-lst (cdr hw-win-lst))
      ;; ミニバッファとアクティブ ウィンドウ以外を処理
      (unless (or (eq hw-tgt-win (minibuffer-window))
                  (eq hw-tgt-win hiwin-active-window)
                  (string-match hiwin-always-active-buffer-name-regexp
                                (buffer-name (window-buffer hw-tgt-win))))
          (progn
            ;; 処理対象ウィンドウを選択
            (select-window hw-tgt-win)
            ;; 処理対象ウィンドウにオーバーレイを設定
            (move-overlay (nth hw-cnt hiwin-overlays)
                          (point-min) (point-max) (current-buffer))
            (overlay-put (nth hw-cnt hiwin-overlays) 'window hw-tgt-win)
            ;; カウンタアップ
            (setq hw-cnt (1+ hw-cnt))
            )
          ))
    ;; 元のアクティブウィンドウを選択
    (when hiwin-server-flag
      (setq hiwin-server-flag 'nil))
    (select-window hiwin-active-window)
    ))

;;;###autoload
(defun hiwin-activate ()
  (interactive)
  (add-hook 'post-command-hook 'hiwin-command-hook)
  )

;;;###autoload
(defun hiwin-deactivate ()
  (interactive)
  (remove-hook 'post-command-hook 'hiwin-command-hook)
  (hiwin-delete-ol)
  )

(defun hiwin-command-hook ()
  ;; 前回の処理からウィンドウ数か，アクティブ ウィンドウが
  ;; 変更されている場合にオーバーレイを再描画
  (unless (and (eq hiwin-overlay-count (count-windows))
               (eq hiwin-active-window (selected-window)))
    (if executing-kbd-macro
        (input-pending-p)
      (condition-case hiwin-error
          (hiwin-draw-ol)
        (error 
         (if (not (window-minibuffer-p (selected-window)))
             (message "[%s] hiwin-mode catched error: %s"
                      (format-time-string "%H:%M:%S" (current-time))
                      hiwin-error) ))
        )
      )
    )
  )

(add-hook 'server-visit-hook (lambda () 
                               (setq hiwin-server-flag t)))

(provide 'hiwin)

;; Local Variables:
;; mode: emacs-lisp
;; coding: utf-8
;; End:

;;; hiwin.el ends here
