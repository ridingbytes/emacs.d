;; -*- emacs-lisp -*-
;;
;; inspired by https://sam217pa.github.io/2016/08/30/how-to-make-your-own-spacemacs
;; https://github.com/sam217pa/emacs-config/blob/develop/python-config.el

;; --- Package ---
(require 'package)
;; No package load during startup
(setq package-enable-at-startup nil)
;; Skip signature check
(setq package-check-signature nil)
;; Package Universe
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
                         ("gnu"       . "http://elpa.gnu.org/packages/")
                         ("melpa"     . "https://melpa.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")))
;; Initialize
(package-initialize)

;; https://github.com/jwiegley/use-package
(unless (package-installed-p 'use-package) ; unless it is already installed
  (package-refresh-contents) ; update packages archive
  (package-install 'use-package)) ; and install the most recent version of use-package
(require 'use-package)
;; log loading activity in the *Messages* buffer
(setq use-package-verbose t)
;; always download packages if not present
(setq use-package-always-ensure t)

;; -------- General Leaders -------

;; Key binding for normal state
(defvar rb--global-leader "SPC")
;; Key binding for non-normal state, e.g. insert, visual, command, emacs
(defvar rb--global-non-normal-leader "C-SPC")

;; -------- Add-ons -------
;; ----------- A ----------

(use-package ace-jump-mode
  :diminish (ace-jump-mode . "ⓐ")
  :bind ("C-j" . ace-jump-mode))


;; Ag.el allows you to search using ag from inside Emacs
;; http://agel.readthedocs.io/en/latest/index.html
(use-package ag
  :config
  (setq ag-highlight-search t)
  (setq ag-reuse-buffers t)

  ;; Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "sa" '(ag-project-at-point :which-key "Ag")
   )
  )

;; Hihghlight symbol under cursor.
;; https://github.com/mhayashi1120/auto-highlight-symbol-mode
(use-package auto-highlight-symbol
  :diminish
  :config
  (global-auto-highlight-symbol-mode t)
  ;; Functions begin with ahs-...
  (setq ahs-default-range 'ahs-range-whole-buffer)
  )

;; ----------- B ----------
;; ----------- C ----------


(use-package company
  :diminish (company-mode . "AC")
  :config
  (global-company-mode)

  (setq company-tooltip-limit 10)
  (setq company-idle-delay 0.2)
  (setq company-echo-delay 0)
  (setq company-minimum-prefix-length 2)
  (setq company-require-match nil)
  (setq company-selection-wrap-around t)
  (setq company-tooltip-align-annotations nil)
  (setq company-tooltip-flip-when-above t)
  (setq company-transformers '(company-sort-by-occurrence)) ; weight by frequency
  (setq company-dabbrev-downcase nil)
  (setq company-dabbrev-ignore-case nil)

  (setq company-backends
        '(
          (
           company-files
           company-dabbrev
           company-keywords
           company-capf
           )
          (company-abbrev company-dabbrev)
          ))


  ;; Anaconda: Code navigation, documentation lookup and completion for Python
  ;; https://github.com/proofit404/anaconda-mode
  (use-package anaconda-mode
    :config
    (add-hook 'python-mode-hook 'anaconda-mode)
    (add-hook 'python-mode-hook 'anaconda-eldoc-mode)
    )

  ;; Anaconda backend for company-mode.
  ;; https://github.com/proofit404/company-anaconda
  (use-package company-anaconda
    :config
    (add-to-list 'company-backends '(company-anaconda :with company-capf))
    (setq company-backends (delete 'company-etags company-backends))
    )

  ;; HTML completion
  (use-package company-web
    :bind (("C-c w" . company-web-html))
    :config
    (add-to-list 'company-backends 'company-web-html))

  (use-package company-statistics
    :config
    (add-hook 'after-init-hook 'company-statistics-mode))

  )

;; CoffeeScript
(use-package coffee-mode
  :mode (("\\.coffee\\'" . coffee-mode))
  :config
  ;; Tab of 2 spaces
  (setq coffee-args-compile '("-c" "--no-header"))

  (custom-set-variables
   '(coffee-indent-like-python-mode t)
   '(coffee-tab-width 2)
   )

  (defun coffee-custom ()
    "coffee-mode-hook"
    (set (make-local-variable 'tab-width) 2))

  (add-hook 'coffee-mode-hook
            '(lambda() (coffee-custom)))
  )


;; Counsel, a collection of Ivy-enhanced versions of common Emacs commands.
;; http://oremacs.com/swiper
(use-package counsel
  :bind*                           ; load on keypress
  (("M-x"     . counsel-M-x)       ; M-x use counsel
   ("C-x C-f" . counsel-find-file) ; C-x C-f use counsel-find-file
   ("C-x C-r" . counsel-recentf)   ; search recently edited files
   ("C-c f"   . counsel-git)       ; search for files in git repo
   ("C-c s"   . counsel-git-grep)  ; search for regexp in git repo
   ("C-c /"   . counsel-ag)        ; search for regexp in git repo using ag
   ("C-c l"   . counsel-locate)    ; search for files or else using locate
   )
  :config

  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "sa" '(counsel-ag :which-key "AG")
   "sf" '(counsel-find-file :which-key "Find")
   "sg" '(counsel-grep :which-key "Grep")
   "sr" '(counsel-rg :which-key "RG")
   "st" '(counsel-etags-find-tag-at-point :which-key "Find Tag")
   )

  ;; https://oremacs.com/2018/03/05/grep-exclude/
  ;; -M 120: truncate all lines that are longer than 120 characters
  (setq counsel-rg-base-command
      "rg -i -M 120 --no-heading --line-number --color never %s .")
  )

(use-package counsel-projectile
  :config
  (counsel-projectile-mode)
  )

(use-package counsel-etags
  )


;; ----------- D ----------

;; https://github.com/emacsmirror/diminish
(use-package diminish)


;; Dumb-jump to definition
(use-package dumb-jump
  :diminish (dumb-jump-mode . "ⓙ")
  :bind
  (("M-g o" . dumb-jump-go-other-window)
   ("M-g g" . dumb-jump-go)
   ("M-g b" . dumb-jump-back))
  :config
  ;;use ivy instead of the default popup for multiple options.
  (setq dumb-jump-selector 'ivy)
)

;; ----------- E ----------

;; Evil Mode
(use-package evil
  :init (evil-mode t) ; enable evil globally at startup
  )

;; Evil Commentary intends to make it easy to comment out (lines of) code
;; https://github.com/linktohack/evil-commentary
(use-package evil-commentary
  :commands (evil-commentary-line)
  )

;; Evil Matchit to jump between matched tags in Emacs
;; https://github.com/redguardtoo/evil-matchit
(use-package evil-matchit
  :commands (evil-matchit-mode)
  :config
  (global-evil-matchit-mode t)
  )

;; Evil Visual Star: Make a visual selection with v or V, and then hit * to
;; search that selection forward, or # to search that selection backward.
;; https://github.com/bling/evil-visualstar
(use-package evil-visualstar
  :commands (evil-visualstar-mode)
  :config
  (global-evil-visualstar-mode t)
  (setq evil-visualstar/persistent nil)
  )

;; Exec PATH from shell, so that the PATH matches the one from the terminal
;; https://github.com/purcell/exec-path-from-shell
(use-package exec-path-from-shell
  :defer 2
  :commands (exec-path-from-shell-initialize
             exec-path-from-shell-copy-env)
  :init
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (exec-path-from-shell-initialize)
  )

;; ----------- F ----------

;; Flycheck
;; http://www.flycheck.org/en/latest
;; https://github.com/flycheck/flycheck
(use-package flycheck
  :diminish (flycheck-mode . "ⓕ")
  :commands flycheck-mode
  :init
  (add-hook 'after-init-hook #'global-flycheck-mode)

  :config
  (setq flycheck-highlighting-mode 'symbols)
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))

  (setq flycheck-python-pylint-executable "python")
  (setq flycheck-python-flake8-executable "python")

  ;; http://www.flycheck.org/en/latest/user/error-list.html#tune-error-list-display
  ;; TODO: use [Shackle](https://github.com/wasamasa/shackle)
  (add-to-list 'display-buffer-alist
             `(,(rx bos "*Flycheck errors*" eos)
              (display-buffer-reuse-window
               display-buffer-in-side-window)
              (side            . bottom)
              (reusable-frames . visible)
              (window-height   . 0.33)))

  ;; http://www.flycheck.org/en/latest/user/error-interaction.html#display-errors
  (use-package flycheck-pos-tip
    :config
    (flycheck-pos-tip-mode)
    )
  )


;; ----------- G ----------

(use-package github-browse-file
  :commands (github-browse-file github-browse-file-blame)
  )

;; Git Gutterlus
;; https://github.com/nonsequitur/git-gutter-plus
(use-package git-gutter+
  :hook (prog-mode . git-gutter+-mode)
  :diminish (git-gutter+-mode . "ⓖ")
  :config
  ;; (global-git-gutter+-mode t)

  ;; Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "gg"  '(:ignore t :which-key "Git Gutter")
   "ggg" '(git-gutter+-show-hunk-inline-at-point :which-key "Show Hunk")
   "ggp" '(git-gutter+-previous-hunk :which-key "Previous Hunk")
   "ggn" '(git-gutter+-next-hunk :which-key "Next Hunk")
   "ggr" '(git-gutter+-do-revert-hunk :which-key "Revert Hunk")
   "ggs" '(git-gutter+-stage-hunks :which-key "Stage Hunk")
   "ggd" '(git-gutter+-popup-hunk :which-key "Show Hunk in Popup")
   )

  ;; git-gutter-fringe+ is a display mode for git-gutter+.el. It uses the buffer
  ;; fringe instead of the buffer margin.
  ;; https://github.com/nonsequitur/git-gutter-fringe-plus
  (use-package git-gutter-fringe+)
  )

;; ----------- H ----------

(use-package hydra
  :config
  (defhydra hydra-zoom (global-map "<f12>")
    "zoom"
    ("+" text-scale-adjust "in")
    ("-" text-scale-adjust "out")
    ("0" text-scale-adjust "standard")
    ))

;; ----------- I ----------

;; Ivy, a generic completion mechanism for Emacs.
(use-package ivy
  :diminish (ivy-mode . "ⓘ")
  :init (ivy-mode 1)        ; enable ivy globally at startup
  :bind (:map ivy-mode-map) ; bind in the ivy buffer
  :config
  (setq ivy-use-virtual-buffers t)   ; extend searching to bookmarks and …
  (setq ivy-height 20)               ; set height of the ivy window
  (setq ivy-count-format "(%d/%d) ") ; count format, from the ivy help page
  )

;; ----------- J ----------

(use-package js2-mode
   :mode "\\.js\\'"
   :config
   (setq js2-basic-offset 2)
   (add-to-list 'interpreter-mode-alist '("nodejs" . js2-mode))
   (add-hook 'js2-mode-hook #'js2-imenu-extras-mode))

;; ----------- K ----------
;; ----------- L ----------
;; ----------- M ----------

;; Markdown
(use-package markdown-mode :ensure t
  :mode (("\\.md\\'" . markdown-mode)
         ("README\\'"   . markdown-mode))
  )

;; Magit
;; https://magit.vc/manual
;; https://github.com/magit/magit
(use-package magit
  :commands (magit-blame
             magit-commit
             magit-commit-popup
             magit-diff-popup
             magit-diff-unstaged
             magit-fetch-popup
             magit-init
             magit-log-popup
             magit-pull-popup
             magit-push-popup
             magit-revert
             magit-stage-file
             magit-status
             magit-unstage-file
             magit-blame-mode)
  :config
  (setq magit-display-buffer-function  ;; Make Magit Fullscreen
	(lambda (buffer)
	  (if magit-display-buffer-noselect
	      ;; the code that called `magit-display-buffer-function'
	      ;; expects the original window to stay alive, we can't go
	      ;; fullscreen
	      (magit-display-buffer-traditional buffer)
	    (delete-other-windows)
	    ;; make sure the window isn't dedicated, otherwise
	    ;; `set-window-buffer' throws an error
	    (set-window-dedicated-p nil nil)
	    (set-window-buffer nil buffer)
	    ;; return buffer's window
	    (get-buffer-window buffer))))
 )

;; ----------- N ----------
;; ----------- O ----------
;; ----------- P ----------

;; Perspective provides tagged workspaces in Emacs, similar to workspaces in windows managers
;; https://github.com/nex3/perspective-el
(use-package perspective
  :config
  (persp-mode t)
  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "p"  '(:ignore t :which-key "Perspective")
   "ps" '(persp-switch :which-key "Switch")
   "pn" '(persp-next :which-key "Next")
   "pp" '(persp-prev :which-key "Previous")
   "pk" '(persp-kill :which-key "Kill")
   "pr" '(persp-rename :which-key "Rename")
   )
  )

;; Perspective Projectile Integration
;; https://github.com/bbatsov/persp-projectile
(use-package persp-projectile
  :config
  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "px" '(projectile-persp-switch-project :which-key "Projectile Switch")
   )
  )

;; Projectile
;; https://github.com/bbatsov/projectile
(use-package projectile
  :diminish (projectile-mode . "ⓟ")
  :bind* (("C-c p p" . projectile-switch-project))
  :commands (projectile-ag
             projectile-switch-to-buffer
             projectile-invalidate-cache
             projectile-find-dir
             projectile-find-file
             projectile-find-file-dwim
             projectile-find-file-in-directory
             projectile-ibuffer
             projectile-kill-buffers
             projectile-multi-occur
             projectile-switch-project
             projectile-recentf
             projectile-remove-known-project
             projectile-cleanup-known-projects
             projectile-cache-current-file
             projectile-project-root
             projectile-mode
             projectile-project-p)
  :config
  (projectile-mode 1)
  (setq projectile-switch-project-action 'projectile-find-file)
  (setq projectile-completion-system 'ivy)

  (defun my-switch-project-hook ()
    "Perform some action after switching Projectile projects."

    (setq omelette (concat (projectile-project-root) "parts/omelette"))
    (if (file-directory-p omelette)
        (progn
          (add-to-list 'python-shell-extra-pythonpaths omelette)
          (message "Added %s to python-shell-extra-pythonpaths" omelette)
          )
      nil)

    ;; Do something interesting here...
    ;;
    ;; `projectile-current-project-files', and `projectile-current-project-dirs' can be used
    ;; to get access to the new project's files, and directories.
    )

  (add-hook 'projectile-after-switch-project-hook #'my-switch-project-hook)
)


;; Powerline is an Emacs version of the Vim powerline.
;; https://github.com/milkypostman/powerline
(use-package powerline
  :config
  (use-package powerline-evil
    :config
    (powerline-evil-vim-color-theme)
    )
  )

;; https://github.com/paetzke/py-isort.el
(use-package py-isort
  :commands (py-isort-region)
  :config
  (setq py-isort-options '("--force-single-line-imports"))
)

;; Python Mode
;; https://github.com/emacsmirror/python-mode
(use-package python
  ;; https://github.com/jwiegley/use-package#modes-and-interpreters
  :mode (("\\.py\\'" . python-mode))
  :interpreter ("python" . python-mode)
  :config

  (if (executable-find "ipython")
      (setq python-shell-interpreter "ipython"
            python-shell-interpreter-args "--simple-prompt -i --pprint")
    (setq python-shell-interpreter "python"))
  )

;; ----------- Q ----------
;; ----------- R ----------

;; Highlights delimiters such as parentheses, brackets or braces according to their depth
;; https://github.com/Fanael/rainbow-delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


(use-package ranger
  :init
  :commands
  (ranger deer)
  :general
  (:keymaps 'ranger-mode-map
   "t" 'ranger-next-file		; j
   "s" 'ranger-prev-file		; k
   "r" 'ranger-find-file		; l
   "-" 'ranger-up-directory		; c
   "j" 'ranger-toggle-mark		; t
   )
  :config
  (evil-set-initial-state 'ranger-mode 'normal)

  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "r"  '(:ignore t :which-key "Ranger")
   "rr" '(ranger :which-key "Ranger")
   "rd" '(deer :which-key "Deer")
   )

  (ranger-override-dired-mode t)
  (setq ranger-omit-regexp "^\\.?#\\|^\\.$\\|^\\.\\.$\\|\.pyc$\\|\.pyo$|\.mo$")

  ;; remove all buffers on close
  (setq ranger-cleanup-eagerly t)

  )

(use-package recentf
  :commands (recentf-mode counsel-recentf)
  :config
  (setq recentf-max-saved-items 50)
  )

(use-package restart-emacs
  :commands restart-emacs
  )


;; https://github.com/dajva/rg.el
(use-package rg
  :config
  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   "s." '(rg-dwim :which-key "RG-dwim")
   "sp" '(rg-project :which-key "RG-project")
   )
  )

;; ----------- S ----------

;; Solarized Theme
;; https://github.com/bbatsov/solarized-emacs
(use-package solarized-theme
  :config
  ;; make the fringe stand out from the background
  (setq solarized-distinct-fringe-background t)
  ;; Don't change the font for some headings and titles
  (setq solarized-use-variable-pitch nil)
  ;; Use less bolding
  (setq solarized-use-less-bold t)
  ;; load the theme
  (load-theme 'solarized-light t)
  )


;; SMEX (sorts the results of M-x by recent used etc.)
;; https://github.com/nonsequitur/smex
(use-package smex)

;; ----------- T ----------

;; Allow to easily move frames.
;; https://www.emacswiki.org/emacs/TransposeFrame
(use-package transpose-frame
  :config
  ;; Prefixed Key Bindings
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader
   )
  )


;; https://github.com/Alexander-Miller/treemacs
(use-package treemacs
  :bind
  (:map global-map ([f10] . #'treemacs-find-file))
  :config
  (progn
    (setq treemacs-follow-after-init          t
          treemacs-width                      35
          treemacs-indentation                2
          treemacs-git-integration            t
          treemacs-collapse-dirs              3
          treemacs-silent-refresh             nil
          treemacs-change-root-without-asking t
          treemacs-sorting                    'alphabetic-desc
          treemacs-show-hidden-files          t
          treemacs-never-persist              nil
          treemacs-is-never-other-window      nil
          treemacs-goto-tag-strategy          'refetch-index
          treemacs-silent-filewatch           t
          treemacs-silent-refresh             t)
    (treemacs-tag-follow-mode t)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t))
  )


(use-package treemacs-projectile
  :ensure t
  :bind
  (:map global-map ([f9] . treemacs-projectile-toggle))
  :config
  (setq treemacs-header-function #'treemacs-projectile-create-header))


;; ----------- U ----------

;; Present nice undo tree, activated with C-x u.
(use-package undo-tree
  :ensure t
  :diminish
  :config
  (global-undo-tree-mode)
  (setq undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t))


;; ----------- V ----------
;; ----------- W ----------

;; Web Mode
;; http://web-mode.org
(use-package web-mode
  :mode (("\\.html\\'" . web-mode)
         ("\\.pt\\'"   . web-mode)
         ("\\.cpt\\'"  . web-mode)
         )
  :config
  ;; Script/code offset indentation (for JavaScript, Java, PHP, Ruby, Go, VBScript, Python, etc.)
  (setq web-mode-code-indent-offset 2)
  ;; CSS offset indentation
  (setq web-mode-css-indent-offset 2)
  ;; HTML element offset indentation
  (setq web-mode-markup-indent-offset 2)
  ;; No tabs
  (setq-default indent-tabs-mode nil)
  )


;; Which-key displays the key bindings following your currently entered incomplete command
;; https://github.com/justbur/emacs-which-key
(use-package which-key
  :diminish (which-key-mode . "ⓦ")
  :init (which-key-mode 1) ; enable which-key globally at startup
  :config

  (setq which-key-sort-order 'which-key-key-order-alpha
        which-key-idle-delay 0.05)
)

;; ----------- X ----------
;; ----------- Y ----------
;; ----------- Z ----------

;; ------ Key Bindings ------

;; General manages keybindings for Evil and non-evil use cases.
(use-package general
  :config
  (general-evil-setup t)
  ;; (setq evil-disable-insert-state-bindings 1)

  ;; map ESC to Quit
  ;; (define-key key-translation-map (kbd "ESC") (kbd "C-g"))

  ;; Global Key Bindings
  (general-def
   "C-<left>"  'windmove-left
   "C-<down>"  'windmove-down
   "C-<up>"    'windmove-up
   "C-<right>" 'windmove-right
   "M-q"       'save-buffers-kill-terminal
   "<f2>"      'save-buffer
   "<f4>"      'delete-window
   "M-q"       'save-buffers-kill-terminal
   "M-c"       'cua-copy-region
   "M-v"       'cua-paste
   "M-z"       'undo
   "C-M-i"     'complete-symbol
   "M-s"       'counsel-ag
   "M-t"       'counsel-projectile
   )

  ;; Key Bindings
  (general-define-key
   :states '(normal)
   "-"   'deer
   )

  ;; SPC-Prefixed
  (general-define-key
   :states '(normal visual insert emacs)
   :prefix rb--global-leader
   :non-normal-prefix rb--global-non-normal-leader

   "TAB" '(ivy-switch-buffer :which-key "Previous Buffer")
   "SPC" '(counsel-M-x :which-key "M-x")

   "a"  '(:ignore t :which-key "Applications")
   "ao" '(counsel-osx-app :which-key "Open App")

   "b"  '(:ignore t :which-key "Buffer")
   "bb" '(ivy-switch-buffer :which-key "Buffers")
   "br" '(counsel-recentf :which-key "Recent Buffers")

   "c"  '(:ignore t :which-key "Comment")
   "cl" '(evil-commentary-line :which-key "Comment")

   "e"  '(:ignore t :which-key "Errors")
   "el" '(flycheck-list-errors :which-key "List")
   "ec" '(flycheck-clear :which-key "Clear")
   "es" '(flycheck-select-checker :which-key "Select Checker")
   "ev" '(flycheck-verify-setup :which-key "Verify Setup")
   "eh" '(flycheck-describe-checker :which-key "Describe Checker")

   "f"  '(:ignore t :which-key "Files")
   "ff" '(counsel-find-file :which-key "Find")
   "fa" '(counsel-ag :which-key "Grep")
   "fc" '(find-user-init-file :which-key "Emacs config")

   "g"  '(:ignore t :which-key "Git")
   "gs" '(magit-status :which-key "Status")
   "gb" '(magit-blame :which-key "Blame")
   "gf" '(counsel-git :which-key "Find")

   "i"  '(:ignore t :which-key "Insert")
   "id" '(insert-date :which-key "Date")
   "ip" '(insert-pdb :which-key "PDB")

   "s"  '(:ignore t :which-key "Search")
   "ss" '(swiper :which-key "Swiper")

   "q"  '(:ignore t :which-key "Quit")
   "qr" '(restart-emacs :which-key "Restart")
   "qq" '(kill-emacs :which-key "Quit")

   "t"  '(:ignore t :which-key "Tags")
   "tr"  '(tags-reset-tags-tables :which-key "Reset")

   "x"   '(:ignore t :which-key "Remove")
   "xw"  '(delete-trailing-whitespace :which-key "Trailing Whitespaces")
   )
 )

;; ------ Config ------

;; delete excess backup versions silently
(setq delete-old-versions -1)
;; use version control
(setq version-control t)
;; make backups file even when in version controlled dir
(setq vc-make-backup-files t)
;; directory to put backups
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")) )
;; don't ask for confirmation when opening symlinked file
(setq vc-follow-symlinks t)
;; transform backups file name
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))
;; inhibit useless and old-school startup screen
(setq inhibit-startup-screen t)
;; silent bell when you make a mistake
(setq ring-bell-function 'ignore)
;; use utf-8 by default
(setq coding-system-for-read 'utf-8 )
(setq coding-system-for-write 'utf-8 )
;; sentence SHOULD end with only a point.
(setq sentence-end-double-space nil)
;; toggle wrapping text at the 80th character
(setq-default fill-column 80)
;; message in the empty scratch buffer opened at startup
(setq initial-scratch-message "")
;; no Dialog Boxes
(setq use-dialog-box nil)
;; always use spaces
(setq-default indent-tabs-mode nil
      tab-width 4)
;; always show Line Numbers
(global-linum-mode t)
;; display line number in mode line
(line-number-mode t)
;; display colum number in mode line
;; (column-number-mode t)
;; show trailing whitespaces
(setq-default show-trailing-whitespace t)
;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
;; alias yes/no to y/n
(defalias 'yes-or-no-p 'y-or-n-p)
;; Ask for confirmation before quitting Emacs
(add-hook 'kill-emacs-query-functions
          (lambda () (y-or-n-p "Do you really want to exit Emacs? "))
          'append)
;; highlight delimiters
(show-paren-mode t)
;; use winner mode
(winner-mode t)
;; no line-wrap
(set-default 'truncate-lines t)
;; make links clickable by default
(define-globalized-minor-mode global-goto-address-mode goto-address-mode goto-address-mode)
(global-goto-address-mode)
;; highlight lines
(global-hl-line-mode t)
;; remember cursor position, for emacs 25.1 or later
(save-place-mode 1)
;; No region when it is not highlighted
(transient-mark-mode 1)
;; Replace marked block with input.
(delete-selection-mode t)
;; No confirmation for large file loading < 500MB
(setq large-file-warning-threshold 500000000)
;; move custom-set-* to separate file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
;; treat underscores as part of the word
(modify-syntax-entry ?_ "w")
;; balance parenthesis
(electric-pair-mode)
;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

(setq-default initial-scratch-message
              (message
               ";; GNU Emacs %s, started on: %s, init time took: %s.\n"
               emacs-version
               (current-time-string)
               (emacs-init-time)))

;; Window configuration
(when window-system
  (tooltip-mode t)
  (tool-bar-mode -1)
  (menu-bar-mode t)
  (scroll-bar-mode -1)
  (blink-cursor-mode -1)
  ;; change default font for current frame
  (add-to-list 'default-frame-alist '(font . "Source Code Pro 14"))
  (set-face-attribute 'default nil :font "Source Code Pro 14")
  ;; frame size
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(fullscreen . maximized))
)

;; Mac specific configuration
(when (eq system-type 'darwin)
  ;; ls does not support --dired; see `dired-use-ls-dired' for more details.
  (setq dired-use-ls-dired nil)
  (setq-default mac-command-modifier 'meta
    mac-option-modifier nil
    mac-allow-anti-aliasing t
    mac-command-key-is-meta t)
  (setq-default locate-command "mdfind")
  (setq delete-by-moving-to-trash t)
  (defun system-move-file-to-trash (file)
    "Use \"trash\" to move FILE to the system trash.
When using Homebrew, install it using \"brew install trash\"."
    (call-process (executable-find "trash") nil nil nil file))
)

;; Auto load mode on file extension
(add-to-list 'auto-mode-alist '("\\.zcml\\'" . xml-mode))
(add-to-list 'auto-mode-alist '("\\.po\\'" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.pot\\'" . conf-mode))

;; css-mode
(add-hook 'css-mode-hook
          '(lambda()
             (message "Activating CSS Mode Hook")
             (setq css-indent-offset 2)
             (setq indent-tabs-mode nil)))

;; coffee-mode
(add-hook 'coffee-mode-hook
          '(lambda()
             (message "Activating Coffee Mode Hook")
             (setq coffee-tab-width 2)))


;; CUA Mode
(cua-mode t)
(setq-default cua-enable-cua-keys nil)
(setq-default cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(setq-default cua-keep-region-after-copy t) ;; Standard Windows behaviour

;; ------ Functions ------

;; open the user init file
(defun find-user-init-file ()
  "Edit `user-init-file'"
  (interactive)
  (find-file-existing user-init-file))

; insert a pdb breakpoint
(defun insert-pdb ()
  "Add an pdb breakpoint"
  (interactive)
  (newline-and-indent)
  (insert "import pdb; pdb.set_trace()")
  (highlight-lines-matching-regexp "^[ ]*import pdb; pdb.set_trace()"))

; insert date
(defun insert-date ()
  "Insert current date yyyy-mm-dd."
  (interactive)
  (when (use-region-p)
    (delete-region (region-beginning) (region-end) )
    )
  (insert (format-time-string "%Y-%m-%d")))

;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Startup-Summary.html#Startup-Summary
(add-hook 'after-init-hook
 (lambda ()
   (message "After-init hook")
   )
 )
(add-hook 'window-setup-hook
 (lambda ()
   (message "All loaded and ready to go!")
   (diminish 'undo-tree-mode "")
   )
 )
