# NixOS移行のためのシステムインベントリ

## Cargo経由でインストール済み（30パッケージ）

### CLIツール
- **alacritty** - ターミナルエミュレータ
- **bat** - シンタックスハイライト付きcat
- **dust** - ディスク使用量アナライザ
- **eza** - 現代的なls代替
- **git-delta** - gitの差分表示
- **hexyl** - Hexビューア
- **hyperfine** - ベンチマークツール
- **procs** - 現代的なps代替
- **tealdeer (tldr)** - 簡易manページ
- **tokei** - コード統計
- **zoxide** - スマートなcd

### 開発ツール
- **jj-cli** - Jujutsuバージョン管理
- **just** - コマンドランナー
- **sccache** - コンパイラキャッシュ
- **mise** - ツールバージョン管理
- **trunk** - WASMウェブバンドラー
- **cargo-update** - Cargoサブコマンド

### ファイル/システムユーティリティ
- **kondo** - プロジェクトクリーナー
- **miniserve** - HTTPファイルサーバー
- **xlsx2csv** - Excel→CSV変換

### プロンプト/シェル
- **starship** - クロスシェルプロンプト
- **starship-jj** - Jujutsu統合
- **mcfly** - シェル履歴検索

### テキスト/ドキュメント処理
- **typst-cli** - Typstコンパイラ
- **typstyle** - Typstフォーマッター
- **pastel** - カラー操作ツール

### ローカルプロジェクト（cargoビルドとして保持）
- **calcyst** (/home/bido/projects/calcyst)
- **modal** (/home/bido/projects/modal)
- **newsnote** (/home/bido/projects/newsnote)
- **wayland_fcitx5_indicator** (/home/bido/projects/wayland_fcitx5_indicator)
- **wmfocus** (/home/bido/projects/wmfocus)

## Pacman経由でインストール済み（337パッケージ）

### デスクトップ環境
- **Hyprland** - Waylandコンポジター
- **GNOME** - デスクトップ環境
- **hyprshell**, **ags-hyprpanel-git** - Hyprland UI
- **polybar**, **dunst**, **rofi**, **wofi**

### ブラウザ
- **firefox** - メインブラウザ
- **zen-browser-bin** - 代替ブラウザ

### 開発環境
- **rustup**, **python**, **nodejs/pnpm**
- **emacs**, **vim**, **visual-studio-code-bin**
- **github-cli**, **deno**, **julia**
- **sbcl**, **clisp**, **ecl**, **quicklisp** - Common Lisp

### メディア/クリエイティブ
- **blender**, **gimp**
- **ardour**, **reaper**, **lmms**, **bitwig-studio** - DAW
- **guitarix**, **carla**, **calf** - オーディオプラグイン
- **mpv** - ビデオプレーヤー

### オーディオシステム
- **pipewire** + **wireplumber**
- **pavucontrol**, **qpwgraph**, **helvum**

### 日本語入力
- **fcitx5** + **fcitx5-mozc**

### システムツール
- **networkmanager**, **bluez**, **tlp**
- **podman** (Docker互換)

### その他重要なもの
- **flatpak**
- **obsidian** - ノート
- **discord_arch_electron**
- **virtualbox**

## 次のステップ

インベントリを作成しました。

**質問：どのアプリケーションから移行を始めますか？**

推奨順序：
1. **CLIツール**（cargo/pacmanの基本的なもの）- 影響範囲が小さく、テストしやすい
2. **シェル設定**（fish, starship, tmux等）
3. **開発環境**（エディタ、言語ツール）
4. **デスクトップ環境**（Hyprland設定）
5. **システム設定**（ネットワーク、Bluetooth等）

まず何から始めますか？
