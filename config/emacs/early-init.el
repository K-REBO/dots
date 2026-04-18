;; ============================================================
;; early-init.el: Emacs 起動前の最速初期化
;; init.el より先に読み込まれ、フレーム生成前に実行される
;; ============================================================

;; GC を最大化して起動中のガベージコレクションを抑制
;; after-init-hook で適切な値に戻す
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; GC 時のフォントキャッシュ圧縮を無効化（処理コスト削減）
(setq inhibit-compacting-font-caches t)

;; フレーム生成前に UI 要素を無効化（init.el での無効化より高速）
(push '(menu-bar-lines . 0)         default-frame-alist)
(push '(tool-bar-lines . 0)         default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;; Nix で全パッケージ管理するため package.el は不要
(setq package-enable-at-startup nil)
