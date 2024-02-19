;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "Fira Code" :size 18)
      doom-variable-pitch-font (font-spec :family "Fira Code") ; inherits `doom-font''s :size
      doom-unicode-font (font-spec :family "Fira Mono")
      doom-big-font (font-spec :family "Fira Code" :size 22)
)

;; something wrong with the ligature
;;(let ((ligatures-to-disable '(:true :false :str :list)))
  ;;(dolist (sym ligatures-to-disable)
    ;;(plist-put! +ligatures-extra-symbols sym nil)))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;(setq doom-theme 'doom-one)
(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; (doom-themes-neotree-config)
  ;; or for treemacs users
  ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  ;; (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Company mode is a standard completion package that works well with lsp-mode.
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 1))

;; Optional - provides snippet support.
(use-package yasnippet
  :ensure t
  :commands yas-minor-mode
  :hook (go-mode . yas-minor-mode))

;; rust
(setq-hook! 'rustic-mode-hook fill-column 100)
(add-hook 'rustic-mode-hook #'rainbow-delimiters-mode)
(setq rustic-indent-offset 4)
(setq rustic-lsp-server 'rust-analyzer
      lsp-rust-clippy-preference "on")

;; chez scheme
(setq geiser-chez-binary (executable-find "scheme"))

;; Typescript/Javascript
(setq js-indent-level 2
      python-indent-offset 2
      typescript-indent-level 2)

(setq prettier-js-args '(
  "--trailing-comma" "all"
  "--bracket-spacing" "false"
))


;; Haskell
(after! haskell-mode
  ;; (set-formatter! 'hindent '("hindent") :modes '(haskell-mode literate-haskell-mode))
  ;; (add-to-list '+format-on-save-enabled-modes 'haskell-mode t)
;;
;;  ;; Improve code navigation in Haskell buffers
  (add-hook 'haskell-mode-hook #'haskell-decl-scan-mode)
  (add-hook 'haskell-mode-hook #'haskell-indentation-mode)
  (setq-hook! 'haskell-mode-hook
    outline-regexp "-- \\*+"
    ;; `haskell-mode' sets the default tab width to eight spaces for some reason
    tab-width 2))

;;(setq lsp-haskell-formatting-provider "brittany")
(setq haskell-stylish-on-save t)

;;Some Haskell preprocessors such as Happy,
;;Alex and uuagc use haskell-like syntax with a few additions.
;;For these files it�~@~Ys useful to have most of the functionality of haskell-mode available.
(add-to-list 'auto-mode-alist '("\\.ag$" . +robbert/basic-haskell-mode))



(use-package scala-mode
  :interpreter
    ("scala" . scala-mode))
(use-package lsp-metals
  :ensure t
  :custom
  ;; Metals claims to support range formatting by default but it supports range
  ;; formatting of multiline strings only. You might want to disable it so that
  ;; emacs can use indentation provided by scala-mode.
  (lsp-metals-server-args '("-J-Dmetals.allow-multiline-string-formatting=off"))
  :hook (scala-mode . lsp))




(setq projectile-project-search-path
      '(
        "~/code/omscs"
        "~/.config"
        "~/org"
        "~/roamnotes"
))


(setq org-directory "~/org/")
(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))
(setq org-pretty-entities t)
(setq org-pretty-entities-include-sub-superscripts t)

;; use red to highlight bold text
;; something wrong with this alist
;;(add-to-list 'org-emphasis-alist
 ;;            '("*" (:foreground "red")))

;; set org-roam
(setq org-roam-directory "~/roamnotes")


(setq avy-all-windows t)
(map! :leader
      :prefix "j"
      :desc "avy-goto-char-timer" "j" #'avy-goto-char-timer)
