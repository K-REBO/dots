;; ============================================================
;; 基本設定
;; ============================================================
(setq inhibit-startup-message t) ; スタートアップ画面を非表示
(setq make-backup-files nil)     ; バックアップファイル（~）を作らない
(setq auto-save-default nil)     ; 自動保存ファイルを作らない
(setq create-lockfiles nil)      ; ロックファイル（.#）を作らない

;; ファイルを再度開いたとき前回のカーソル位置を復元
(save-place-mode t)

;; 外部でファイルが変更された場合に自動で再読み込み
(global-auto-revert-mode t)
;; dired バッファも自動更新
(setq global-auto-revert-non-file-buffers t)

;; ビープ音・警告音を完全に無効化
(setq ring-bell-function 'ignore)
(setq visible-bell nil)

;; ============================================================
;; UI
;; ============================================================
(menu-bar-mode -1)               ; メニューバーを非表示
(tool-bar-mode -1)               ; ツールバーを非表示
(scroll-bar-mode -1)             ; スクロールバーを非表示
(column-number-mode t)           ; モードラインに列番号を表示
(show-paren-mode t)              ; 対応する括弧をハイライト
(global-display-line-numbers-mode t) ; 全バッファで行番号を表示

;; ============================================================
;; インデント
;; ============================================================
(setq-default indent-tabs-mode nil) ; タブの代わりにスペースを使用
(setq-default tab-width 4)          ; タブ幅を4に設定

;; ============================================================
;; キーバインド調整
;; ターミナルでは C-BACKSPACE が C-h として届くため backward-kill-word に割り当て
;; ヘルプは F1 で代替
;; ============================================================
(global-set-key (kbd "C-h") 'backward-kill-word)
(global-set-key (kbd "<f1>") 'help-command)

;; ============================================================
;; 入力メソッド
;; C-\ で Emacs 組み込み IME が起動するのを無効化
;; 日本語入力は fcitx5（GUI）を使用する
;; ============================================================
(setq default-input-method nil)

;; ============================================================
;; use-package の初期化
;; ============================================================
(require 'use-package)

;; ============================================================
;; テーマ（doom-dracula）
;; ============================================================
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-dracula t)
  ;; ビープ音の代わりにモードラインをフラッシュ
  (doom-themes-visual-bell-config)
  ;; org-mode のフォント設定を最適化
  (doom-themes-org-config))

;; ============================================================
;; nyan-mode: モードラインにニャンキャットでスクロール位置を表示
;; ============================================================
(use-package nyan-mode
  :config
  (when (display-graphic-p)
    (nyan-mode t)))

;; ============================================================
;; doom-modeline: リッチなモードライン
;; 初回は M-x nerd-icons-install-fonts を実行してフォントを導入する
;; ============================================================
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 4)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

;; ============================================================
;; dimmer: 非アクティブウィンドウを薄暗く表示してフォーカスを明確化
;; ============================================================
(use-package dimmer
  :config
  (dimmer-configure-which-key)   ; which-key ポップアップは除外
  (dimmer-configure-magit)       ; magit バッファは除外
  (setq dimmer-fraction 0.4)     ; 0.0（変化なし）〜1.0（完全に暗く）、0.4 が自然
  (dimmer-mode t))

;; ============================================================
;; Rainbow Delimiters: 対応する括弧を深さごとに色分け
;; ============================================================
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; ============================================================
;; ターミナル（-nw）起動時の設定
;; zsh alias: emacs='emacs -nw' でターミナル起動をデフォルトとする
;; ============================================================

;; 背景透過: doom-dracula がセットする背景色をテーマロード後に上書きし、
;; ターミナルエミュレータ側の透過設定を活かす
(defun my/terminal-transparent-bg ()
  (unless (display-graphic-p)
    (set-face-background 'default "unspecified-bg")
    (set-face-background 'fringe "unspecified-bg")))

(add-hook 'after-init-hook #'my/terminal-transparent-bg)

(unless (display-graphic-p)
  (xterm-mouse-mode 1) ; マウス操作を有効化
  ;; マウスホイールでスクロール
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line)

  ;; システムクリップボード連携（wl-copy / wl-paste 経由）
  ;; GUI モードは Emacs が自動で連携するため不要
  (defvar my/wl-copy-process nil)

  (defun my/wl-copy (text)
    "テキストを wl-copy でシステムクリップボードに書き込む"
    (setq my/wl-copy-process
          (make-process :name "wl-copy"
                        :buffer nil
                        :command '("wl-copy" "-f" "-n")
                        :connection-type 'pipe
                        :noquery t))
    (process-send-string my/wl-copy-process text)
    (process-send-eof my/wl-copy-process))

  (defun my/wl-paste ()
    "wl-paste からシステムクリップボードを読み込む"
    ;; 自分自身がコピー中の場合は nil を返して二重取得を防ぐ
    (unless (and my/wl-copy-process
                 (process-live-p my/wl-copy-process))
      (shell-command-to-string "wl-paste -n | tr -d \r")))

  (setq interprogram-cut-function   #'my/wl-copy)
  (setq interprogram-paste-function #'my/wl-paste))

;; ============================================================
;; GUI 起動時のみフォントサイズ設定
;; ============================================================
(when (display-graphic-p)
  (set-face-attribute 'default nil :height 130))

;; ============================================================
;; electric-pair-mode: 括弧・クォートの自動補完（組み込み）
;; () [] {} "" '' `` を入力すると閉じ括弧を自動挿入
;; ============================================================
(electric-pair-mode t)

;; ============================================================
;; yasnippet: スニペット展開（TAB で展開）
;; ============================================================
(use-package yasnippet
  :config
  (yas-global-mode t))

;; yasnippet-snippets: 各言語の公式スニペット集
(use-package yasnippet-snippets)

;; ============================================================
;; undo-tree: undo 履歴をツリー構造で管理・可視化
;; C-x u でツリー表示、分岐した編集履歴を復元可能
;; ============================================================
(use-package undo-tree
  :config
  (global-undo-tree-mode)
  ;; undo-tree の履歴ファイルを一箇所にまとめる
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo-tree"))))

;; ============================================================
;; flycheck: リアルタイムのエラー・警告表示
;; ============================================================
(use-package flycheck
  :hook (after-init . global-flycheck-mode))

;; ============================================================
;; multiple-cursors: 複数カーソル編集
;; C-c m l : 選択行に複数カーソル
;; C-c m n : 次の同一単語にカーソル追加
;; C-c m p : 前の同一単語にカーソル追加
;; C-c m a : バッファ内の全同一単語にカーソル追加
;; ============================================================
(use-package multiple-cursors
  :bind (("C-c m l" . mc/edit-lines)
         ("C-c m n" . mc/mark-next-like-this)
         ("C-c m p" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)))

;; ============================================================
;; drag-stuff: 行・選択範囲を M-up / M-down で入れ替え
;; ============================================================
(use-package drag-stuff
  :demand t
  :config
  (drag-stuff-global-mode t)
  (define-key drag-stuff-mode-map (kbd "M-p") #'drag-stuff-up)
  (define-key drag-stuff-mode-map (kbd "M-n") #'drag-stuff-down))

;; ============================================================
;; Eglot: LSP クライアント（Emacs 29+ 組み込み）
;; ============================================================
(use-package eglot
  :hook
  ((rust-ts-mode       . eglot-ensure) ; rust-analyzer
   (zig-mode           . eglot-ensure) ; zls
   (nix-ts-mode        . eglot-ensure) ; nil
   (js-ts-mode         . eglot-ensure) ; typescript-language-server
   (typescript-ts-mode . eglot-ensure) ; typescript-language-server
   (tsx-ts-mode        . eglot-ensure) ; typescript-language-server
   (python-ts-mode     . eglot-ensure) ; pyright
   (bash-ts-mode       . eglot-ensure) ; bash-language-server
   (sh-mode            . eglot-ensure) ; bash-language-server
   (go-ts-mode         . eglot-ensure) ; gopls
   (html-mode          . eglot-ensure) ; vscode-html-language-server
   (mhtml-mode         . eglot-ensure) ; vscode-html-language-server
   (json-ts-mode       . eglot-ensure) ; vscode-json-language-server
   (svelte-mode        . eglot-ensure) ; svelte-language-server
   (toml-ts-mode       . eglot-ensure) ; taplo
   (yaml-ts-mode       . eglot-ensure) ; yaml-language-server
   (markdown-mode      . eglot-ensure) ; marksman
   (css-ts-mode        . eglot-ensure) ; vscode-css-language-server
   (css-mode           . eglot-ensure)  ; vscode-css-language-server
   (typst-ts-mode      . eglot-ensure)) ; tinymist
  :config
  ;; nix-ts-mode → nil LSP サーバー
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nil")))
  ;; svelte-mode → svelte-language-server
  (add-to-list 'eglot-server-programs '(svelte-mode . ("svelteserver" "--stdio")))
  ;; markdown-mode → marksman
  (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman" "server")))
  ;; typst-ts-mode → tinymist
  (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist"))))

;; ============================================================
;; Magit: Git クライアント
;; ============================================================
(use-package magit
  :bind ("C-x g" . magit-status))

;; ============================================================
;; which-key: キーバインドのヒントをポップアップ表示
;; ============================================================
(use-package which-key
  :config
  (which-key-mode))

;; ============================================================
;; Vertico: ミニバッファの補完 UI
;; ============================================================
(use-package vertico
  :config
  (vertico-mode))

;; ============================================================
;; Orderless: スペース区切りで絞り込める補完スタイル
;; ============================================================
(use-package orderless
  :custom
  ;; orderless: スペース区切りで絞り込み
  ;; orderless-flex: 文字順が合えばハイフンや区切りを無視してマッチ
  (completion-styles '(orderless basic))
  (orderless-matching-styles '(orderless-literal
                                orderless-prefixes
                                orderless-flex)))

;; ============================================================
;; Consult: バッファ・ファイル・行の検索・ナビゲーション
;; ============================================================
(use-package consult
  :bind (("C-s"   . consult-line)   ; 行検索
         ("C-x b" . consult-buffer))) ; バッファ切替

;; ============================================================
;; Corfu: モダンな補完 UI（completion-at-point ベース）
;; ============================================================
(use-package corfu
  :custom
  (corfu-auto t)           ; 自動でポップアップ
  (corfu-auto-delay 0.2)   ; 入力から表示までの遅延（秒）
  (corfu-auto-prefix 2)    ; 何文字入力で候補を出すか
  (corfu-cycle t)          ; 候補リストを循環
  :config
  (global-corfu-mode)
  ;; ターミナル（-nw）では child frame が使えないため corfu-terminal で代替
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))

;; ============================================================
;; Cape: 補完ソースの追加（ファイルパス・バッファ内単語など）
;; ============================================================
(use-package cape
  :config
  (add-to-list 'completion-at-point-functions #'cape-file)    ; ファイルパス補完
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)) ; バッファ内単語補完

;; ============================================================
;; treesit-auto: Tree-sitter による文法ハイライトを自動適用
;; rust / markdown は treesit-auto に含まれる
;; ============================================================
(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

;; ============================================================
;; nix-ts-mode: Nix ファイルのシンタックスハイライト
;; ============================================================
(use-package nix-ts-mode
  :mode "\\.nix\\'")

;; ============================================================
;; zig-mode: Zig ファイルのシンタックスハイライト
;; ============================================================
(use-package zig-mode
  :mode "\\.zig\\'")

;; ============================================================
;; yaml-ts-mode: .yaml / .yml 両方に適用（treesit-auto の補完）
;; ============================================================
(use-package yaml-ts-mode
  :mode (("\\.yaml\\'" . yaml-ts-mode)
         ("\\.yml\\'"  . yaml-ts-mode)))

;; ============================================================
;; svelte-mode: Svelte ファイルのシンタックスハイライト
;; ============================================================
(use-package svelte-mode
  :mode "\\.svelte\\'")

;; ============================================================
;; typst-ts-mode: Typst ファイルのシンタックスハイライト・LSP
;; ============================================================
(use-package typst-ts-mode
  :mode "\\.typ\\'"
  :config
  (defun my/typst-apply-overlays ()
    "treesit クエリで heading/strong を overlay で強調（font-lock を回避）"
    (when (treesit-available-p)
      (remove-overlays (point-min) (point-max) 'my-typst t)
      (let ((root (treesit-buffer-root-node 'typst)))
        (dolist (capture (treesit-query-capture
                          root
                          '((heading)  @heading
                            (strong)   @strong
                            (raw_blck) @raw
                            (raw_span) @raw)))
          (let* ((type (car capture))
                 (node (cdr capture))
                 (face (pcase type
                         ('heading 'font-lock-keyword-face)
                         ('strong  'bold)
                         ('raw     'font-lock-string-face)))
                 (ov (make-overlay (treesit-node-start node)
                                   (treesit-node-end node))))
            (overlay-put ov 'my-typst t)
            (overlay-put ov 'face face))))))

  (add-hook 'typst-ts-mode-hook
            (lambda ()
              (my/typst-apply-overlays)
              ;; バッファ変更後に再適用
              (add-hook 'after-change-functions
                        (lambda (&rest _)
                          (my/typst-apply-overlays))
                        nil t))))

;; ============================================================
;; image-mode: 画像ビューア（組み込み）
;; PNG / JPG / GIF / SVG / WebP 等を直接表示
;; n / p で次・前の画像、+ / - でズーム、r で回転
;; ============================================================
(use-package image-mode
  :ensure nil
  :custom
  (image-use-external-converter t)) ; ImageMagick で未対応フォーマットも表示

;; ============================================================
;; markdown-mode: Markdown ファイルのシンタックスハイライト
;; ============================================================
(use-package markdown-mode
  :mode (("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  ;; コードブロック内を対応するメジャーモードでハイライト
  (markdown-fontify-code-blocks-natively t)
  ;; $...$ / $$...$$ の数式をハイライト
  (markdown-enable-math t)
  ;; 見出し・太字・斜体などのフォントを強調表示
  (markdown-header-scaling t)
  (markdown-hide-markup nil)
  ;; M-RET で箇条書き・チェックボックスを継続（RET は通常改行）
  (markdown-indent-on-enter t)
  :config
  ;; ``` 入力時に閉じブロックを自動挿入してカーソルを中に置く
  (defun my/markdown-electric-code-block ()
    (when (looking-back "^```" (line-beginning-position))
      (save-excursion
        (insert "\n\n```"))))
  (add-hook 'markdown-mode-hook
            (lambda ()
              ;; ` の自動ペア補完（インラインコード用）
              (setq-local electric-pair-pairs
                          (append electric-pair-pairs '((?` . ?`))))
              (add-hook 'post-self-insert-hook
                        #'my/markdown-electric-code-block nil t))))
