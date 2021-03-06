;;; init.el --- My init.el
;;; https://github.com/daichimukai/dotfiles

;;; Commentary:
;;;
;;; How did that?
;;;
;;; Q. How do I open this url in a browser?
;;; A. M-x browse-url-at-point
;;;
;;; Q. Icon font is missing.
;;; A. Try `M-x all-the-icons-install-fonts'.


;;; Code:


;;; straight.el
;;; https://github.com/raxod502/straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(cd "~/")

(prefer-coding-system 'utf-8)
(setq custom-file (locate-user-emacs-file "custom.el"))
(setq inhibit-startup-message t) ; no startup screen
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq-default indent-tabs-mode nil)
(scroll-bar-mode -1) ; disable scroll bar
(tool-bar-mode -1)
(column-number-mode +1)
(when (eq system-type 'darwin)
  (add-hook 'after-init-hook #'(lambda () (set-frame-parameter nil 'fullscreen 'maximized)))
  (if (functionp 'mac-auto-operator-composition-mode)
      (mac-auto-operator-composition-mode)))

;;; use-package
;;; https://github.com/jwiegley/use-package
(straight-use-package 'use-package)
(straight-use-package 'diminish)
(eval-when-compile (require 'use-package))
(eval-and-compile (require 'bind-key))
(eval-and-compile (require 'diminish))

(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

(defmacro safe-diminish (file mode &optional newname)
  `(with-eval-after-load ,file
     (diminish ,mode ,newname)))
(safe-diminish "emacs-lisp" 'emacs-lisp-mode "el")
(safe-diminish "undo-tree" 'undo-tree-mode)
(safe-diminish "eldoc" 'eldoc)

;;; For writing elisp

;;; dash.el
;;; https://github.com/magnars/dash.el
(use-package dash :no-require t)

;;; s.el
;;; https://github.com/magnars/s.el
(use-package s :no-require t)

;;; f.el
;;; https://github.com/rejeep/f.el
(use-package f :no-require t)


;;; Font
;;;
;;; hannkaku moji to zennkaku moji no haba no hi wo 1:2 ni shitai
;;; はんかく もじ と ぜんかく もじ の はば の ひ を 1:2 に したい
;;;
;;; (ó﹏ò。) < HELP ME! I cannot explain the accurate reason why this config works as exactly I want
;;;
;;; TODO: write code to switch fonts easily

;;; Hack
;;; https://sourcefoundry.org/hack/
;;; (set-face-attribute 'default 'nil :family "Hack" :height 105)

;;; Anonymous Pro
;;; (set-face-attribute 'default 'nil :family "Anonymous Pro" :height 120)

;;; Sarasa
;;; https://github.com/be5invis/Sarasa-Gothic
(if (eq system-type 'darwin)
      (set-face-attribute 'default 'nil :family "Sarasa Mono J" :height 160)
  (set-face-attribute 'default 'nil :family "Sarasa Mono J" :height 120))

;;; MyricaM
;;; https://myrica.estable.jp/myricamhistry/

;;; If you want to use Hack font config, uncomment the following line
; (set-fontset-font t 'japanese-jisx0208 (font-spec :family "MyricaM M" :size 12.0))
; (set-fontset-font t 'japanese-jisx0208 (font-spec :family "MyricaM M" :size 13.5))
; (set-fontset-font t 'japanese-jisx0208 (font-spec :family "Sarasa Term J" :size 12.0))

;; For macOS
;(when (eq system-type 'darwin)
  ;; Anonymous Pro
  ;; https://www.marksimonson.com/fonts/view/anonymous-pro
  ;(set-face-attribute 'default 'nil :family "Anonymous Pro" :height 160)

  ;; Ricty
  ;; https://www.rs.tus.ac.jp/yyusa/ricty.html
  ; (set-fontset-font t 'japanese-jisx0208 (font-spec :family "Ricty" :size 18.0)))

;;; fira-code-mode
(use-package fira-code
  :load-path "lisp"
  :no-require t
  :straight nil
  :diminish nil
  :disabled t
  :hook (prog-mode . fira-code-mode)
  :config (fira-code-mode--setup))


;;; my utils
(defun my/open-init-el ()
  "Open init.el."
  (interactive)
  (if (get-buffer "init.el")
      (let ((buffer (get-buffer "init.el")))
	(switch-to-buffer buffer))
    (find-file (expand-file-name "~/.emacs.d/init.el"))))

(defun my/reload-init-el ()
  "Reload init.el."
  (interactive)
  (eval-buffer (find-file-noselect (expand-file-name "~/.emacs.d/init.el")))
  (message "Reloaded ~/.emacs.d/init.el"))

(defun my/switch-to-scratch-buffer ()
  "Switch to a scratch buffer."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*")))

;;; http://d.hatena.ne.jp/kiwanami/20091222/1261504543
(defun my/other-window-or-split ()
  "Eval `other-window'. If there is only one window, split holizontally in advance."
  (interactive)
  (when (one-window-p)
    (split-window-horizontally))
  (other-window 1))
(bind-key "C-t" 'my/other-window-or-split)

(defun my/blink-mode-line (color)
  "Blink mode line with COLOR."
  (let ((orig-fb (face-background 'mode-line)))
    (set-face-background 'mode-line color)
    (run-with-timer 0.1 nil (lambda (fb) (set-face-background 'mode-line fb)) orig-fb)))

(defmacro my/blink-mode-line--color (color)
  (list
   'defun (intern (format "my/blink-mode-line--%s" (replace-regexp-in-string " " "-" (format "%s" color)))) ()
   (list 'my/blink-mode-line (format "%s" color))))

(defmacro my/blink-mode-line--defun-colors (&rest colors)
  (cons 'progn
	(mapcar (lambda (color)
		  (let ((color-name (format "%s" color)))
		    (list
		     'defun (intern (format "my/blink-mode-line-%s"
                                            (replace-regexp-in-string " " "-" color-name)))
                     ()
		     (list 'my/blink-mode-line color-name))))
		colors)))

(my/blink-mode-line--defun-colors pink "sky blue" white black green)

;; (setq ring-bell-function 'my/blink-mode-line-pink)
;; (add-hook 'after-save-hook 'my/blink-mode-line-sky-blue)


;;; which-key
(use-package which-key
  :defer nil
  :init
  (setq which-key-enable-extended-define-key t)
  :config (which-key-mode))


;;; leader key
(define-prefix-command 'my-leader-map) ;; my leader key
(bind-key "C-z" my-leader-map)
(bind-key "SPC" 'execute-extended-command my-leader-map)

;;; file map
(define-prefix-command 'my-file-map)
(bind-keys :map my-leader-map
	   :prefix "f" ;; bind to '<leader>f'
	   :prefix-map my-file-map
	   ("f" . find-file))

;;; buffer map
(define-prefix-command 'my-buffer-map)
(bind-keys :map my-leader-map
	   :prefix "b" ;; bind to '<leader>b'
	   :prefix-map my-buffer-map
	   ("b" . switch-to-buffer)
	   ("s" . my/switch-to-scratch-buffer))

;;; git map
(define-prefix-command 'my-git-map)
(bind-keys :map my-leader-map
	   :prefix "g" ;; bind to '<leader>g'
	   :prefix-map my-git-map
	   ("s" . magit-status))

;;; init.el map
(define-prefix-command 'my-init-el-map)
(bind-keys :map my-file-map
	   :prefix "e" ;; bind to '<leader>fe'
	   :prefix-map my-init-el-map
	   ("d" . my/open-init-el))


;;; vcs

;;; git.el
(use-package git
  :functions git-run
  :no-require t)

;;; magit
(use-package magit
  :defer t
  :init
  (setq vc-follow-symlinks t)
  :no-require t)


;;; evil
(use-package evil
  :disabled t
  :init
  (setq evil-want-abbrev-expand-on-insert-exit nil)
  :config
  (define-key evil-normal-state-map (kbd "SPC") 'my-leader-map) ;; change the leader key to space
  (define-key evil-visual-state-map (kbd "SPC") 'my-leader-map) ;; change the leader key to space
  (evil-mode)
  :demand t)

;; escape all by "fd"
(use-package evil-escape
  :after evil
  :diminish nil
  :config (evil-escape-mode)
  :demand t
  :disabled t
  :no-require t)

(use-package evil-magit
  :after (evil magit)
  :no-require t
  :init
  :disabled t
  (add-hook 'magit-mode-hook #'(lambda () (require 'evil-magit)))
  (setq evil-magit-state 'normal))


;;; UI

;;; doom-themes
;;; https://github.com/hlissner/emacs-doom-themes
(use-package doom-themes
  :no-require t
  :defer nil
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  :custom-face
  (doom-modeline-bar ((t (:background "#6272a4"))))
  :config
  (doom-themes-visual-bell-config)
  (load-theme 'doom-dracula t))

;;; golden-ratio.el
;;; https://github.com/roman/golden-ratio.el
(use-package golden-ratio
  :demand t
  :no-require t
  :diminish "φ"
  :disabled t
  :config
  (golden-ratio-mode 1)
  (setq golden-ratio-exclude-buffer-names '("*goals*" "*response*"))
  (add-to-list 'golden-ratio-extra-commands 'magit-status))

;;; rainbow-delimiters
;;; https://github.com/Fanael/rainbow-delimiters
(use-package rainbow-delimiters
  :straight t
  :no-require t
  :hook (prog-mode . rainbow-delimiters-mode))


;;; Completion

;;; ivy
;;; https://github.com/abo-abo/swiper
(use-package ivy
  :demand t
  :no-require t
  :config
  (setq ivy-count-format "(%d/%d) ")
  (setq ivy-re-builders-alist
	'((t . ivy--regex-plus)))
  (ivy-mode 1))

(use-package counsel
  :demand t
  :no-require t
  :config
  (counsel-mode))

(use-package swiper
  :no-require t
  :bind (("M-s s" . swiper)))

;;; company-mode
;;; http://company-mode.github.io/
(use-package company
  :no-require t
  :diminish ""
  :init (setq company-tooltip-align-annotations t)
  :hook (prog-mode . company-mode))

;;; Language Server Protocol
(use-package eglot
  :no-require t)


;;; syntax check

;;; flycheck
;;; https://github.com/flycheck/flycheck
(use-package flycheck
  :no-require t
  :config
  (global-flycheck-mode))


;;; input method

;;; ddskk
;;; https://github.com/skk-dev/ddskk
(use-package ddskk
  :no-require t)


;;; Utility

;;; hydra
;;; https://github.com/abo-abo/hydra
(use-package hydra :no-require)

;;; quickrun.el
;;; https://github.com/syohex/emacs-quickrun
(use-package quickrun
  :no-require t)

;;; yasnippet
(use-package yasnippet
  :no-require t
  :defer nil
  :after which-key
  :init
  (setq yas-snippet-dirs (list (expand-file-name "snippets" user-emacs-directory)))
  :config
  (use-package yasnippet-snippets :defer t :straight t)
  (define-key my-leader-map "y" '("YASnippet"))
  (bind-keys  :map my-leader-map
	      :prefix "y"
	      :prefix-map my-yasnippet-map
	      :prefix-docstring "YASnippet"
	      ("s" . yas-insert-snippet)
	      ("n" . yas-new-snippet)
	      ("r" . yas-recompile-all)
	      ("R" . yas-reload-all)
	      ("v" . yas-visit-snippet-file))
  (yas-global-mode 1))

;;; projectile
;;; https://github.com/bbatsov/projectile
(use-package projectile
  :no-require t
  :defer nil
  :config
  (projectile-mode +1))

;;; smartparens
;;; https://github.com/Fuco1/smartparens
(use-package smartparens
  :no-require
  :config
  (require 'smartparens-config)
  :hook (prog-mode . smartparens-mode))

;;; ParEdit
(use-package paredit
  :no-require t)

;;; multiple-cursors.el
;;; https://github.com/magnars/multiple-cursors.el
(use-package multiple-cursors
  :no-require t)

;;; org-mode
;;; https://www.orgmode.org/ja/index.html
;;;
;;; See https://github.com/raxod502/radian/blob/develop/emacs/radian.el for the hack below
(eval-and-compile (require 'subr-x)
		   (require 'git))

(defun org-git-version ()
  "The Git version of `org-mode`.
Inserted by installing `org-mode` or when a release is made."
  (let ((git-repo (expand-file-name
                   "straight/repos/org/" user-emacs-directory)))
    (string-trim
     (git-run "describe"
	      "--match=release\*"
	      "--abbrev=6"
	      "HEAD"))))

(defun org-release ()
  "The release version of `org-mode`.
Inserted by installing `org-mode` or when a release is made."
  (require 'git)
  (let ((git-repo (expand-file-name
                   "straight/repos/org/" user-emacs-directory)))
    (string-trim
     (string-remove-prefix
      "release_"
      (git-run "describe"
               "--match=release\*"
               "--abbrev=0"
               "HEAD")))))

(provide 'org-version)
(use-package org
  :no-require t
  :config
  (org-indent-mode)
  (with-eval-after-load 'org-capture
    ;; https://ox-hugo.scripter.co/doc/org-capture-setup/
    (defun org-hugo-new-subtree-post-capture-template ()
      "Returns `org-capture' template string for new Hugo post.
See `org-capture-templates' for more infomation. "
      (let* ((title (read-from-minibuffer "Post title: "))
	     (fname (org-hugo-slug title))
	     (date (format-time-string "%Y-%m-%d" (current-time))))
	(s-join "\n"
		`(
		  ,(concat "* TODO " title)
		  ":PROPERTIES:"
		  ,(concat ":EXPORT_FILE_NAME: " fname)
		  ,(concat ":EXPORT_DATE: " date)
		  ":END:"
		  "%?\n"))))
    (add-to-list 'org-capture-templates
		 '("b"
		   "Blog post"
		   entry
		   (file+olp "blog.org" "Posts")
		   (function org-hugo-new-subtree-post-capture-template)))))

;;; ox-hugo
;;; https://github.com/kaushalmodi/ox-hugo
(use-package ox-hugo
  :defer t
  :no-require t
  :after ox
  :init
  (setq org-hide-leading-stars t)
  :config
  (require 'ox-hugo-auto-export))


;;; Language specific configurations

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; R u s t
;;;
;;; TODO: major mode map for rust mode
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; rust-mode
;;; https://github.com/rust-lang/rust-mode
(use-package rust-mode
  :no-require t
  :mode
  ("\\.rs\\'" . rust-mode)
  :init
  (setq rust-format-on-save t)
  :config
  (bind-key "TAB" 'company-indent-or-complete-common rust-mode-map))

;;; racer
;;; https://github.com/racer-rust/emacs-racer
(use-package racer
  :no-require t
  :after rust-mode
  :hook ((rust-mode . racer-mode)
	 (racer-mode . eldoc-mode)))

;;; cargo.el
;;; https://github.com/kwrooijen/cargo.el
(use-package cargo
  :no-require t
  :after rust-mode
  :hook (rust-mode . cargo-minor-mode))

;;; Proof General
;;; https://github.com/ProofGeneral/PG
(use-package proof-general
  :no-require t
  :mode ("\\.v\\'" . coq-mode))

;;; company-coq-mode
;;; https://github.com/cpitclaudel/company-coq
(use-package company-coq
  :after (company proof-general)
  :no-require t
  :hook (coq-mode . company-coq-mode))

;;; lean-mode
;;; https://github.com/leanprover/lean-mode
(use-package lean-mode
  :no-require t)
(use-package company-lean
  :no-require t
  :after (company lean-mode))

;;; slime
(use-package slime
  :init
  (setq inferior-lisp-program "sbcl")
  (setq slime-contribs '(slime-fancy))
  :no-require)

;;; eros
;;; https://github.com/xiongtx/eros
(use-package eros
  :no-require t)

;;; rg
(use-package rg
  :no-require t)

(use-package smart-mode-line
  :disabled t
  :no-require t
  :defer nil
  :init
  (setq sml/theme 'dark)
  :config
  (sml/setup))

;;; doom-modeline
;;; https://github.com/seagle0128/doom-modeline
(use-package doom-modeline
  :no-require t
  :defer nil
  :config
  (doom-modeline-mode 1))

(use-package olivetti
  :no-require t)

;;; avy
;;; https://github.com/abo-abo/avy
(use-package avy
  :defer nil
  :config
  (global-set-key (kbd "C-:") 'avy-goto-char))

(use-package editorconfig
  :no-require
  :config
  (editorconfig-mode +1))

(use-package tuareg
  :no-require t)

;;; https://github.com/fxbois/web-mode
(use-package web-mode
  :init
  (setq web-mode-attr-indent-offset nil)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-sql-indent-offset 2)
  :no-require t
  :mode
  ("\\.js\\'" . web-mode))

;;; https://github.com/prettier/prettier-emacs
(use-package prettier-js
  :no-require t
  :hook (web-mode . prettier-js-mode))

;;; https://github.com/sonatard/clang-format
(use-package clang-format
  :no-require t)

(defhydra hydra-zoom (global-map "<f3>")
  "zoom in/out"
  ("g" text-scale-increase "in")
  ("l" text-scale-decrease "out")
  ("0" (text-scale-set 0) "reset" :color blue))

(defhydra hydra-multiple-cursors (global-map "<f4>" :hint nil)
  "
Multiple Cursors

^One^                     ^Many^                       ^Special
^^^^^-----------------------------------------------------------------------
_w_: next word            _W_: all word                _R_: reverse order
_s_: next symbol          _S_: all symbol              _u_: sort
_M-w_: prev word          _l_: all lines               _0_: increasing numbers from 0
^   ^                     _a_: beginnings of lines     _1_: increasing numbers from 1
^   ^                     _e_: ends of lines           _c_: Increasing letters
^   ^                     _r_: region                  ^
^   ^                     _d_: dwim                    ^

_q_: quit
"
  ("w" mc/mark-next-like-this-word)
  ("s" mc/mark-next-like-this-symbol)
  ("M-w" mc/mark-previous-like-this-word)

  ("W" mc/mark-all-words-like-this :color blue)
  ("S" mc/mark-all-symbols-like-this :color blue)
  ("l" mc/edit-lines :color blue)
  ("r" mc/mark-all-in-region :color blue)
  ("a" mc/edit-beginnings-of-lines :color blue)
  ("e" mc/edit-ends-of-lines :color blue)
  ("d" mc/mark-all-dwim)

  ("R" mc/reverse-regions)
  ("u" mc/sort-regions)
  ("0" mc/insert-numbers)
  ("1" (mc/insert-numbers 1))
  ("c" mc/insert-letters)

  ("q" nil))

(defhydra hydra-entry (:color blue)
  "
Welcome to hydra!
"
  ("<f3>" hydra-zoom/body "zoom")
  ("<f4>" hydra-multiple-cursors/body "multiple cursors"))
(global-set-key (kbd "<f2>") 'hydra-entry/body)

(provide 'init)
;;; init.el ends here
