;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2022 Bido Nakamura

;; Author: Bido Nakamura (holmes10031208@gmail.com)

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))



(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

(provide 'init)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                                                                                       ;;;
;;;;   888     888                           .d8888b.                  .d888d8b            ;;;
;;;;   888     888                          d88P  Y88b                d88P" Y8P            ;;;
;;;;   888     888                          888    888                888                  ;;;
;;;;   888     888.d8888b  .d88b. 888d888   888        .d88b. 88888b. 888888888 .d88b.     ;;;
;;;;   888     88888K     d8P  Y8b888P"     888       d88""88b888 "88b888   888d88P"88b    ;;;
;;;;   888     888"Y8888b.88888888888       888    888888  888888  888888   888888  888    ;;;
;;;;   Y88b. .d88P     X88Y8b.    888       Y88b  d88PY88..88P888  888888   888Y88b 888    ;;;
;;;;    "Y88888P"  88888P' "Y8888 888        "Y8888P"  "Y88P" 888  888888   888 "Y88888    ;;;
;;;;                                                                                888    ;;;
;;;;                                                                           Y8b d88P    ;;;
;;;;                                                                            "Y88P"     ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; server
(server-start)

;;;;   _                _        _     _ _
;;;;  | |    ___   ___ | | _____| |   (_) | _____
;;;;  | |   / _ \ / _ \| |/ / __| |   | | |/ / _ \
;;;;  | |__| (_) | (_) |   <\__ \ |___| |   <  __/
;;;;  |_____\___/ \___/|_|\_\___/_____|_|_|\_\___|
                                            
 
;; Theme

(require 'doom-themes)
(if (display-graphic-p)
    (load-theme 'doom-dracula t))

;; Fonts
(setq default-frame-alist
      '((font . "Source Code Pro 16")))
;;日本語フォント
(if (display-graphic-p)
(set-fontset-font (frame-parameter nil 'font)
                  'japanese-jisx0208
                  (font-spec :family "IPA P明朝" :size 26)))

;;行の折り返し
(set-default 'truncate-lines t)

;; 自動括弧閉じ
(smartparens-mode t)

;; line number
(global-linum-mode t)
(set-face-foreground 'linum "dimgray")

;; scratch msgを取り除く
(setq initial-scratch-message nil)

;; Alpha channel
;;(add-to-list 'default-frame-alist '(alpha . (1.00 1.00)))


;; nobackup such as *~
(setq make-backup-files nil)
;;; nobackup such as #*#
(setq auto-save-default nil)

;;Disable Scroll Bar
(scroll-bar-mode -1)

;; pair bracket
(show-paren-mode 1)

;; Disable beep
(setq ring-bell-function 'ignore)


(setq-default tab-width 4)

;; Rainbow Delimiters
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;;(setq nyan-animate-nyancat t)

;; Doom modeline
(require 'doom-modeline)
(doom-modeline-mode 1)

;; Neotree
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)
;;(neotree-toggle)


;;Dashboard board
(require 'dashboard)
(setq dashboard-startup-banner "~/.emacs.d/static/logo/RMS.png")
(setq dashboard-set-file-icons t)
(setq dashboard-banner-logo-title "Shut the fuck up and write some CODE")
(setq dashboard-set-heading-icons t)
;;Dashboard render
(dashboard-setup-startup-hook)

;; Beacon
(beacon-mode 1)


;; nyan-mode
(nyan-mode t)

;; indent with TABs(not SPACES due to TAB is user-friendly so that those who read code can change indent-width thierself and it is good for reduce disk-space)
(setq-default indent-tabs-mode t)


;; (electric-pair-mode t)

;;comment color
;;(set-face-foreground 'font-lock-comment-face "#3ea250") ;;comment-color from VS
;;(set-face-foreground 'font-lock-comment-face "#5a8b7c") ;;comment-color VS + dracula

;;  _                _        _     _ _          _____ _   _ ____
;; | |    ___   ___ | | _____| |   (_) | _____  | ____| \ | |  _ \
;; | |   / _ \ / _ \| |/ / __| |   | | |/ / _ \ |  _| |  \| | | | |
;; | |__| (_) | (_) |   <\__ \ |___| |   <  __/ | |___| |\  | |_| |
;; |_____\___/ \___/|_|\_\___/_____|_|_|\_\___| |_____|_| \_|____/
                                                                

;; for cua-mode
(cua-selection-mode t)


(leaf markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode))

(use-package lsp-mode
  :custom ((lsp-inhibit-message t)
         (lsp-message-project-root-warning t)
         (create-lockfiles nil))
  :hook   (prog-major-mode . lsp-prog-major-mode-enable))

(use-package lsp-ui
  :after lsp-mode
  :custom (scroll-margin 0)
  :hook   (lsp-mode . lsp-ui-mode))

(use-package company-capf
  :after (lsp-mode company yasnippet)
  :defines company-backends
  :functions company-backend-with-yas
  :init (cl-pushnew (company-backend-with-yas 'company-capf) company-backends))


;; Typescript
(add-hook 'typescript-mode-hook #'lsp)
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))


;; Javascript
(add-to-list 'auto-mode-alist '("\\.js\\;" . js2-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rust
(add-to-list 'exec-path (expand-file-name "~/.cargo/rust-analyzer/rust-analyzer"));;the path of rust-analyzer
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(use-package rust-mode
  :ensure t
  :custom rust-format-on-save t)


(use-package cargo
  :ensure t
  :hook (rust-mode . cargo-minor-mode))

;; Which key

;;(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;;(leaf electric
;;  :doc "window maker and Command loop for `electric' modes"
;;  :tag "builtin"
;;  :added "2020-08-27"
;;  :init (electric-pair-mode 1))

(leaf ivy
  :doc "Incremental Vertical completYon"
  :req "emacs-24.5"
  :tag "matching" "emacs>=24.5"
  :url "https://github.com/abo-abo/swiper"
  :emacs>= 24.5
  :ensure t
  :blackout t
  :leaf-defer nil
  :custom ((ivy-initial-inputs-alist . nil)
           (ivy-use-selectable-prompt . t))
  :global-minor-mode t
  :config
  (leaf swiper
    :doc "Isearch with an overview. Oh, man!"
    :req "emacs-24.5" "ivy-0.13.0"
    :tag "matching" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :bind (("C-s" . swiper)))

  (leaf counsel
    :doc "Various completion functions using Ivy"
    :req "emacs-24.5" "swiper-0.13.0"
    :tag "tools" "matching" "convenience" "emacs>=24.5"
    :url "https://github.com/abo-abo/swiper"
    :emacs>= 24.5
    :ensure t
    :blackout t
    :bind (("C-S-s" . counsel-imenu)
           ("C-x C-r" . counsel-recentf))
    :custom `((counsel-yank-pop-separator . "\n----------\n")
              (counsel-find-file-ignore-regexp . ,(rx-to-string '(or "./" "../") 'no-group)))
    :global-minor-mode t))

(leaf prescient
  :doc "Better sorting and filtering"
  :req "emacs-25.1"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :custom ((prescient-aggressive-file-save . t))
  :global-minor-mode prescient-persist-mode)
  
(leaf ivy-prescient
  :doc "prescient.el + Ivy"
  :req "emacs-25.1" "prescient-4.0" "ivy-0.11.0"
  :tag "extensions" "emacs>=25.1"
  :url "https://github.com/raxod502/prescient.el"
  :emacs>= 25.1
  :ensure t
  :after prescient ivy
  :custom ((ivy-prescient-retain-classic-highlighting . t))
  :global-minor-mode t)

(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "minor-mode" "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :emacs>= 24.3
  :ensure t
  :bind (("M-n" . flycheck-next-error)
         ("M-p" . flycheck-previous-error))
  :global-minor-mode global-flycheck-mode)

(leaf company
  :doc "Modular text completion framework"
  :req "emacs-24.3"
  :tag "matching" "convenience" "abbrev" "emacs>=24.3"
  :url "http://company-mode.github.io/"
  :emacs>= 24.3
  :ensure t
  :blackout t
  :leaf-defer nil
  :bind ((company-active-map
          ("M-n" . nil)
          ("M-p" . nil)
          ("C-s" . company-filter-candidates)
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)
          ("<tab>" . company-complete-selection))
         (company-search-map
          ("C-n" . company-select-next)
          ("C-p" . company-select-previous)))
  :custom ((company-idle-delay . 0)
           (company-minimum-prefix-length . 1)
           (company-transformers . '(company-sort-by-occurrence)))
  :global-minor-mode global-company-mode)

(leaf company-c-headers
  :doc "Company mode backend for C/C++ header files"
  :req "emacs-24.1" "company-0.8"
  :tag "company" "development" "emacs>=24.1"
  :added "2020-03-25"
  :emacs>= 24.1
  :ensure t
  :after company
  :defvar company-backends
  :config
  (add-to-list 'company-backends 'company-c-headers))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-idle-delay 0)
 '(company-minimum-prefix-length 1)
 '(company-transformers '(company-sort-by-occurrence))
 '(counsel-find-file-ignore-regexp "\\(?:\\.\\(?:\\.?/\\)\\)")
 '(counsel-yank-pop-separator "
----------
")
 '(custom-safe-themes
   '("234dbb732ef054b109a9e5ee5b499632c63cc24f7c2383a849815dacc1727cb6" default))
 '(default-input-method "japanese-skk")
 '(ivy-initial-inputs-alist nil)
 '(ivy-prescient-retain-classic-highlighting t)
 '(ivy-use-selectable-prompt t)
 '(package-archives
   '(("gnu" . "https://elpa.gnu.org/packages/")
     ("melpa" . "https://melpa.org/packages/")
     ("org" . "https://orgmode.org/elpa/")))
 '(package-selected-packages
   '(all-the-icons tide smartparens js2-mode typescript-mode centaur-tabs use-package lsp-ui lsp-mode cargo lispy markdown-mode yaml-mode ddskk which-key rainbow-mode ghub pacmacs dashboard-hackernews rust-mode srcery-theme ace-window doom-themes rainbow-delimiters dracula-theme spacemacs-theme company-c-headers company flycheck ivy-prescient prescient counsel swiper ivy blackout el-get hydra leaf-keywords))
 '(prescient-aggressive-file-save t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
 ;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
