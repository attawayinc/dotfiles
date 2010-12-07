;;
;; Ian's Emacs config
;;
;; A lot of things stolen from EmacsWiki and threads like
;; http://news.ycombinator.com/item?id=1654164

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst gui (not (eq window-system 'nil))
  "Are we running window system?")

(defconst macgui (string-equal window-system "ns")
  "Are we running as a Max OS X app?")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Libraries and snippets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add all subdirectories in the vendor dir to the load path.

(defun add-subfolders-to-load-path (parent-dir) ;; from bbatsov
  "Adds all first level `parent-dir' subdirs to the Emacs load path."
  (dolist (f (directory-files parent-dir))
    (let ((name (concat parent-dir "/" f)))
      (when (and (file-directory-p name)
                 (not (equal f ".."))
                 (not (equal f ".")))
        (add-to-list 'load-path name)))))

(add-subfolders-to-load-path "~/.emacs.d/vendor")
(add-to-list 'load-path "~/.emacs.d/vendor")

;; Load extra Emacs lisp snippets.

(defun load-snippet (name)
  "Loads the file in elisp-dir with the given name."
  (load (concat "~/.emacs.d/elisp/" name)))

(load-snippet "rename-file-and-buffer")
(load-snippet "cleanup-unused-buffers")
(load-snippet "swap-windows")

;; Executables might be somewhere else
(add-to-list 'exec-path "~/bin")
(add-to-list 'exec-path "/opt/local/bin")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Pile o' settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Be quiet at startup.
(setq inhibit-startup-message nil)
(setq inhibit-startup-screen t)

;; No damn beeping.
(setq ring-bell-function 'ignore)

;; Don't save backup files everywhere.
(setq make-backup-files nil )
(setq auto-save-default nil)

;; Hide the menu, toolbar and scroll bars.
(when (not gui)
  (menu-bar-mode 1))
(when gui
  (scroll-bar-mode -1)
  (tool-bar-mode -1))

;; By default, use spaces, not tabs, and display 2 spaces per tab.
(defconst default-indent-level 2)
(setq indent-tabs-mode nil)
(setq tab-width default-indent-level)
(setq js-indent-level default-indent-level)
(setq css-indent-offset default-indent-level)

;; Make search case-insensitive.
(setq-default case-fold-search t)

;; Make the region act like common text selection.
(transient-mark-mode 1)

;; Highlight parentheses.
(show-paren-mode 1)

;; All of my terminals are Unicode-aware.
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)

;; Display the line and column number in the modeline.
(setq line-number-mode t)
(setq column-number-mode t)
(line-number-mode t)
(column-number-mode t)

;; Make all "yes or no" prompts show "y or n" instead.
(fset 'yes-or-no-p 'y-or-n-p)

;; Allow narrowing. (`C-x n w' gets you out of this.)
(put 'narrow-to-defun 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Color theme.
(require 'color-theme)
(require 'zenburn)
(color-theme-initialize)
;; (when gui
;;   (color-theme-goldenrod) ;; This sets some things that railscasts doesn't.
;;   (color-theme-railscasts))

;; Do the right thing with whitespace. Seriously. The Right Thing.
;; Also provides handy "clean up this file" commands and highlights errors.
(require 'ethan-wspace)
(global-ethan-wspace-mode 1)

;; C-w kills a word or region depending on context. (DWIM)
(defun backward-kill-word-or-kill-region (&optional arg)
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))
(global-set-key (kbd "C-w") 'backward-kill-word-or-kill-region)

;; <Enter> should be smart. (DWIM)
(global-set-key (kbd "RET") 'newline-and-indent)

;; IDO mode: Better buffer and file completion.
;; http://www.emacswiki.org/emacs/InteractivelyDoThings
(require 'ido)
(ido-mode 1)
;; Get rid of the annoying .ido.last file
;; (http://stackoverflow.com/questions/1371076)
(setq
 ido-enable-last-directory-history nil
 ido-record-commands nil
 ido-max-work-directory-list 0
 ido-max-work-file-list 0)
(global-set-key (kbd "C-;") 'ido-switch-buffer)

;; Display IDO results vertically, rather than horizontally
;; (from timcharper, jpkotta via EmacsWiki)
(setq ido-decorations
      (quote ("\n-> " "" "\n   " "\n   ..." "[" "]"
              " [No match]" " [Matched]" " [Not readable]"
              " [Too big]" " [Confirm]")))
(defun ido-disable-line-trucation ()
  (set (make-local-variable 'truncate-lines) nil))
(add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-trucation)

;; Switch-to-previous-buffer
(global-set-key (kbd "C-=") 'switch-to-previous-buffer)
(defun switch-to-previous-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))

;; C-z toggles between shell. (C-x C-z still suspends.)
(require 'shell)
(global-set-key (kbd "C-z") 'shell)
(define-key shell-mode-map (kbd "C-z") 'bury-buffer)

;; Make buffer names unique.
(require 'uniquify)
(setq
 uniquify-buffer-name-style 'reverse
 uniquify-separator ":")

;; Mac OS X customizations
(when macgui

  ;; Raph makes nice fonts :)
  (set-default-font "Inconsolata 14")

  ;; Make the command key the meta key.
  (setq mac-command-modifier 'meta)

  ;; Make Cmd-~ do the right thing.
  (global-set-key (kbd "M-`") 'ns-next-frame))

;; Make the Undo system like Vim's, but with a sexy visualizer.
;; http://www.emacswiki.org/emacs/UndoTree
(require 'undo-tree)
(global-undo-tree-mode t)

;; browse-kill-ring
(require 'browse-kill-ring)
(global-set-key (kbd "C-x C-r") 'browse-kill-ring)

;; Keep the cursor kinda centered, like scrolloff in vim
(require 'centered-cursor-mode)
;; (global-centered-cursor-mode +1)

;; Use ack instead of grep - http://betterthangrep.com/
(load-library "ack")
(defalias 'grep 'ack)

;; Auto-complete
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories
             "~/.emacs.d/vendor/auto-complete-1.3.1/ac-dict")
(ac-config-default)
(setq ac-auto-show-menu t)
(setq ac-auto-start t)

;; Edit remote files - http://www.gnu.org/software/emacs/manual/tramp.html
;; (require 'tramp)
;; (setq tramp-default-method "scp")

;; Settings for editing text
(setq sentence-end-double-space nil)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; HTML-editing settings
(when (>= emacs-major-version 23)
  (load "~/.emacs.d/vendor/nxhtml-2.08/autostart.el")

  ;; No silly background colors for different modes.
  (setq mumamo-background-colors nil)

  ;; Set as the Django default for HTML files.
  (add-to-list 'auto-mode-alist '("\\.html$" . django-html-mumamo-mode)))

;; "Sparkup" or "Zen-coding" makes churning out HTML easier.
(require 'zencoding-mode)
(add-hook 'sgml-mode-hook 'zencoding-mode) ;; Auto-start on any markup modes

;; dired settings
(require 'dired)
(define-key dired-mode-map (kbd "u") 'dired-up-directory)
(define-key dired-mode-map (kbd "U") 'dired-unmark)

;; Markdown
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-hook 'markdown-mode-hook 'flyspell-mode)

;; YAML
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(define-key yaml-mode-map (kbd "RET") 'newline-and-indent)

;; Open init.el
(defun open-init-dot-el ()
  (interactive)
  (find-file (expand-file-name "~/.emacs.d/init.el")))
(global-set-key (kbd "C-M-0") 'open-init-dot-el)

;; Maybe I want to do some reading in Emacs?
(require 'info)
(setq Info-directory-list
      (cons (expand-file-name "~/.dotfiles/info")
            Info-directory-list))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Enable code-folding
(add-hook 'python-mode-hook
          '(lambda ()
             (flyspell-prog-mode)
             (hs-minor-mode 1)
             (hs-hide-all)))

;; Use M-RET to toggle hiding
(add-hook 'hs-minor-mode-hook
          '(lambda ()
             (define-key python-mode-map (kbd "M-RET") 'hs-toggle-hiding)))

;; testing
;; (add-hook 'python-mode-hook '(lambda () (flyspell-prog-mode)))

;; Use our local installation of Pymacs and rope.
(setenv "PYTHONPATH"
        (concat (getenv "PYTHONPATH") ":"
                (expand-file-name "~/.emacs.d/python")))

;; Basic Pymacs setup instructions.
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

;; ;; Load Rope.
;; (when (>= emacs-major-version 23)
;;   (require 'pymacs)
;;   (pymacs-load "ropemacs" "rope-"))

;; ;; Rope Settings
;; (setq ropemacs-enable-shortcuts nil)
;; (setq ropemacs-local-prefix "C-0")

;; Python/Flymake/Pylint attempt.
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customize settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(isearch ((((class color) (min-colors 8)) (:background "grey25"))))
 '(lazy-highlight ((((class color) (min-colors 8)) (:background "grey25"))))
 '(linum ((t (:foreground "#666" :height 0.75))))
 '(mumamo-background-chunk-major ((t nil)))
 '(mumamo-background-chunk-submode1 ((((class color) (min-colors 88) (background dark)) nil)))
 '(show-paren-match ((t (:background "grey20"))))
 '(vertical-border ((((type tty)) (:inherit mode-line-inactive :foreground "black"))))
 '(viper-minibuffer-emacs ((((class color)) (:background "darkseagreen2" :foreground "Black"))))
 '(viper-minibuffer-insert ((((class color)) nil)))
 '(viper-search ((((class color)) (:background "#330" :foreground "yellow")))))
