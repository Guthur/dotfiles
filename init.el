(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/")
             t)
;; (add-to-list 'package-archives
;;  	     '("marmalade" . "http://marmalade-repo.org/packages/")
;;  	     t)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/")
             t)

(package-initialize)

(add-to-list 'load-path "~/.emacs.d/elisp/")

(eval-when-compile
  (require 'use-package))
(require 'diminish)                ;; if you use :diminish
(require 'bind-key)

(use-package helm
  :ensure t
  :bind (("M-x"         . helm-M-x)
         ("C-x b"       . helm-mini)
         ("C-x C-f"     . helm-find-files)
         ("C-c h"       . helm-command-prefix)
         ("M-Y"         . helm-show-kill-ring)
         ("C-c C-c M-x" . execute-extended-command)) ;; This is your old M-x.
  :config (progn
            (require 'helm-config)
            (when (executable-find "curl")
              (setq helm-google-suggest-use-curl-p t))
            (helm-mode 1)
            (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
            (define-key helm-map (kbd "C-i")   'helm-execute-persistent-action)
            (define-key helm-map (kbd "C-z")   'helm-select-action))
  :diminish helm-mode)

(use-package helm-projectile
  :ensure t
  :bind (("C-x M-f" . helm-projectile-find-file)
         ("C-c C-f" . helm-projectile-find-file))
  :config (projectile-global-mode))

(use-package expand-region
  :ensure
  :bind (("C-=" . er/expand-region)))

(use-package clojure-mode
  :ensure t)

(use-package cider
  :ensure t)

(use-package paredit
  :ensure t
  :bind (("{" . paredit-open-curly)
         ("}" . paredit-close-curly)))

(use-package magit-stgit
  :ensure t)

(use-package magit
  :ensure t
  :bind ("C-c m" . magit-status)
  :init (setq magit-last-seen-setup-instructions "1.4.0")
  :config (add-hook 'magit-mode-hook 'magit-stgit-mode))

(use-package expand-region
  :ensure t)

(use-package eldoc
  :ensure t
  :config (eldoc-add-command
           'paredit-backward-delete
           'paredit-close-round))

(defun erc-ghost-maybe (server nick)
  "Send GHOST message to NickServ if NICK ends with `erc-nick-uniquifier'.
The function is suitable for `erc-after-connect'."
  (when (string-match (format "\\(.*?\\)%s+$" erc-nick-uniquifier) nick)
    (let ((nick-orig (match-string 1 nick))
          (password erc-session-password))
      (erc-message "PRIVMSG" (format "NickServ GHOST %s %s"
                                     nick-orig password))
      (erc-cmd-NICK nick-orig)
      (erc-message "PRIVMSG" (format "NickServ identify %s %s"
                                     nick-orig password)))))

(use-package erc
  :ensure t
  :init
  (progn
    (erc-autojoin-mode 1)
    (setq erc-autojoin-channels-alist
          '(("freenode.net" "#lisp" "#lispgames" "#gamedev")))
    (setq erc-server-history-list '("irc.freenode.net"))))

(defun plist-to-alist (the-plist)
  (defun get-tuple-from-plist (the-plist)
    (when the-plist
      (cons (car the-plist) (cadr the-plist))))

  (let ((alist '()))
    (while the-plist
      (add-to-list 'alist (get-tuple-from-plist the-plist))
      (setq the-plist (cddr the-plist))) alist))

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")
(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

;; *** LISP CONFIG *** ;;
(defun lisp-hook ()
  (enable-paredit-mode)
  (setq show-paren-mode 1)
  (local-set-key (kbd "RET") 'electrify-return-if-match))

(add-hook 'emacs-lisp-mode-hook 'lisp-hook)
(add-hook 'lisp-mode-hook 'lisp-hook)
(add-hook 'lisp-interaction-mode-hook 'lisp-hook)
(add-hook 'scheme-mode-hook 'lisp-hook)

;; *** CIDER/CLOJURE CONFIG *** ;;
(defun clojure-hook-fn ()
  (cider-turn-on-eldoc-mode)
  (enable-paredit-mode)
  (setq show-paren-mode 1))

(use-package cider
  :ensure t
  :init (setq cider-lein-command "lein.bat")
  :config
  (progn (add-hook 'cider-mode-hook 'clojure-hook-fn)
         (add-hook 'cider-repl-mode-hook 'clojure-hook-fn)))

(require 'cider-eldoc)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(magit-use-overlays nil)
 '(safe-local-variable-values
   (quote
    ((Package . CL-USER)
     (Base . 10)
     (Package . FLEXI-STREAMS)
     (Syntax . COMMON-LISP)
     (eval define-clojure-indent
           (match 1)
           (fact 1)
           (facts 1)
           (provided 0)
           (for-all 1))
     (eval define-clojure-indent
           (match 1)
           (fact 1)
           (facts 1)
           (provided 0))
     (eval define-clojure-indent
           (fact 1)
           (facts 1)
           (provided 0))
     (eval put
           (quote s/defrecord)
           (quote clojure-backtracking-indent)
           (quote
            (4 4
               (2))))
     (eval when
           (fboundp
            (quote rainbow-mode))
           (rainbow-mode 1))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package solarized-theme
  :ensure t)

(load-theme 'solarized-dark)
(cond
 ((or (eq system-type 'gnu/windows-nt)
      (eq system-type 'gnu/cygwin))
  (set-default-font "consolas-12"))
 ((eq system-type 'gnu/linux)
  (set-default-font "inconsolata-12")))

;; GLOBAL KEY BIND ;;
(global-set-key (kbd "RET") 'electrify-return-if-match)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(show-paren-mode t)
(setq-default indent-tabs-mode nil)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)

(load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
(setq inferior-lisp-program "sbcl")
