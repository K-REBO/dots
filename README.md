# NixOS移行用設定ファイル

このリポジトリには、完全に再現可能なNixOS + Home-Manager環境設定が含まれています。

**特徴:**
- 🚀 **完全にポータブル**: `git clone` してすぐに使える
- 📦 **85+パッケージ**: CLI、開発環境、デスクトップ環境すべて含む
- 🎨 **完全設定済み**: Hyprland、fcitx5、壁紙、スクリプトすべて含む
- 🔄 **再現可能**: どのマシンでも同じ環境を構築
- 📝 **宣言型**: すべての設定がコードとして管理

このディレクトリにはArch LinuxからNixOSへ段階的に移行するための設定が含まれています。

## 構造

```
dots/
├── flake.nix                   # Flakeエントリーポイント
├── home.nix                    # Home-Managerメイン設定
├── configuration.nix           # NixOS完全設定
├── nixos-reference.nix         # NixOS参考設定（旧）
├── .gitignore                  # Git除外設定
├── modules/                    # Home-Managerモジュール（19個）
│   # Phase 1: CLIツール・基本設定
│   ├── cli-tools.nix           # CLIツール
│   ├── shell.nix               # Fish + Starship
│   ├── alacritty.nix           # Alacritty
│   ├── bash.nix                # Bash
│   ├── zsh.nix                 # Zsh
│   ├── git.nix                 # Git
│   ├── vim.nix                 # Vim
│   # Phase 2A: 開発環境
│   ├── vscode.nix              # VSCode
│   ├── language-tools.nix      # 言語ツール
│   # Phase 2B: WMツール
│   ├── rofi.nix                # Rofi
│   ├── wofi.nix                # Wofi
│   ├── polybar.nix             # Polybar
│   # Phase 3: デスクトップ環境
│   ├── hyprland.nix            # Hyprland
│   ├── fcitx5.nix              # fcitx5日本語入力
│   ├── xremap.nix              # xremapキーリマップ
│   # Phase 4: システムサービス
│   ├── pipewire.nix            # Pipewireオーディオ
│   # Phase 5: アプリケーション・テーマ
│   ├── fonts.nix               # フォント設定
│   ├── applications.nix        # アプリケーション
│   └── themes.nix              # GTK/Qtテーマ
├── config/                     # アプリケーション設定ファイル
│   ├── hypr/
│   │   ├── hyprland.conf       # Hyprland設定
│   │   ├── hypridle.conf       # アイドル管理設定
│   │   ├── hyprlock.conf       # ロック画面設定
│   │   ├── wallpapers/         # 壁紙（11ファイル、27MB）
│   │   └── scripts/            # カスタムスクリプト
│   ├── fcitx5/                 # fcitx5設定
│   │   ├── config
│   │   ├── profile
│   │   └── conf/
│   └── xremap/                 # xremap設定
│       └── config.yaml         # キーリマップ設定
├── INSTALLATION-GUIDE.md       # インストールガイド
├── PRE-MIGRATION-CHECKLIST.md  # 移行前チェックリスト
├── MIGRATION-TODO.md           # 移行状況
├── INVENTORY.md                # システムインベントリ
└── README.md                   # このファイル
```

## Phase 1: CLIツール・基本設定 ✅

### 移行済みのツール

**ファイル管理・表示:**
- bat, eza, dust, hexyl

**検索・移動:**
- zoxide

**開発ツール:**
- just, hyperfine, tealdeer (tldr), tokei, jujutsu (jj)

**Git関連:**
- git-delta, jujutsu

**その他:**
- sccache, kondo, miniserve, typst, pastel, mise

**シェル統合:**
- fish (エイリアス、初期化スクリプト)
- starship (プロンプト + jujutsu統合)
- mcfly (履歴検索)
- GitHub CLI

**ターミナル:**
- alacritty (完全な設定移行済み)

**シェル設定:**
- bash (エイリアス、プロンプト、PATH、履歴設定)
- zsh (エイリアス、プロンプト、補完、シンタックスハイライト、履歴設定)

**開発ツール設定:**
- git (ユーザー情報、delta統合、エイリアス)
- vim (行番号、タブ設定、キーバインド)

## Phase 2A: 開発環境 ✅

**エディタ:**
- VSCode (テーマ、フォント、設定、拡張機能)
  - Dracula At Night テーマ
  - Source Code Pro 15pt
  - Rust Analyzer統合
  - GitHub Copilot有効

**言語ツール:**
- Python3 + pip
- Node.js + pnpm
- Deno
- Go
- C/C++ (gcc, clang)
- ビルドツール (cmake, make)

## Phase 2B: WMツール ✅

**アプリケーションランチャー:**
- rofi (Wayland版)
- wofi (カスタムテーマ、Papirusアイコン)

**ステータスバー:**
- polybar (カスタム設定、モジュール、スクリプト統合)
  - CPU、メモリ、バッテリー表示
  - ネットワーク情報
  - カスタムスクリプト対応

## Phase 3: デスクトップ環境 ✅

**Wayland コンポジター:**
- Hyprland（完全な設定）
  - モニター設定（eDP-1: 2560x1600@60）
  - カスタムキーバインド（Emacs風 pnfb）
  - リサイズモード（i3風）
  - アニメーション設定
  - 自動起動設定

**Hyprland関連ツール:**
- hyprlock（スクリーンロッカー）
- hypridle（アイドル管理）
- swww（壁紙管理）
- hyprpanel（ステータスバー）
- hyprshell

**入力メソッド:**
- fcitx5 + Mozc（日本語入力）
- GTK/Qt統合
- wayland_fcitx5_indicator（ローカルプロジェクト）

**キーリマップ:**
- xremap（CapsLock → Control）
- systemdサービスで自動起動

**その他:**
- スクリーンショットツール（grimblast, grim, slurp, satty）
- 通知（dunst, libnotify）
- メディアコントロール（brightnessctl, playerctl）

**既存設定の保持:**
- 壁紙ディレクトリ（~/.config/hypr/wallpapers/ - 11ファイル、27MB）
- スクリプトディレクトリ（~/.config/hypr/scripts/）
- 設定ファイル（hyprland.conf, hypridle.conf, hyprlock.conf）
- xremap設定（config.yaml）

## Phase 4: システムサービス ✅

### ユーザーレベルサービス（Home-Manager管理）

**Pipewire オーディオシステム:**
- Pipewire本体
- PulseAudio互換レイヤー
- ALSA統合
- JACK統合
- Wireplumber（セッションマネージャー）
- GUIツール（pavucontrol, qpwgraph, helvum）

### システムレベルサービス（NixOS移行時に設定）

**重要:** 以下のサービスはHome-Managerでは管理できません。
`nixos-reference.nix` に参考設定を記載しています。

**ネットワーク:**
- NetworkManager（WiFi/有線接続管理）
- iwd backend

**Bluetooth:**
- bluez + blueman

**電源管理:**
- TLP（バッテリー閾値、CPU設定）
- upower

**ハードウェア:**
- AMD GPU設定
- ファームウェア自動更新

## Phase 5: アプリケーション・テーマ ✅

### アプリケーション（applications.nix）

**ブラウザ:**
- Firefox（設定付き）

**生産性:**
- Obsidian（ノート）

**メディア:**
- mpv（ビデオプレーヤー、設定付き）
- feh（画像ビューア）
- kazam, simplescreenrecorder（録画）

**ダウンローダー:**
- yt-dlp
- aria2
- transmission-gtk（Torrent）

**開発・コンテナ:**
- podman + podman-compose

**ファイル管理:**
- Dolphin（ファイルマネージャ）
- gparted（パーティション）
- rsync

**コミュニケーション:**
- Discord

**ネットワーク:**
- nmap
- cloudflared

### テーマ（themes.nix）

**GTKテーマ:**
- Dracula（ダークテーマ）
- Papirus-Dark（アイコン）
- ダークモード設定

**Qt統合:**
- GTKテーマを使用
- Waylandサポート

### フォント（fonts.nix）

- Notoフォントファミリー
- Nerd Fonts
- プログラミングフォント
- 日本語フォント

### まだ移行していないもの

**ローカルプロジェクト（Cargo）:**
- calcyst, modal, newsnote, wayland_fcitx5_indicator, wmfocus
  → これらはローカルビルドのため、そのままcargoで管理

**cargo-update:**
- Nix環境では不要（Nixでパッケージ管理）

**xlsx2csv:**
- 必要に応じて後で追加

**秘密情報（.env）:**
- `~/.env` ファイルを作成して、API keyなどの秘密情報を管理
- bashrcから自動的にsourceされます（bash.nixに設定済み）

---

## 🚀 クイックスタート（新しいマシンでの使い方）

このリポジトリをクローンするだけで、環境を再現できます。

### 1. リポジトリのクローン

```bash
git clone <your-repo-url> ~/dots
cd ~/dots
```

### 2. Nixのインストール（まだの場合）

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 3. Flakesの有効化

`~/.config/nix/nix.conf` または `/etc/nix/nix.conf` に追加:
```
experimental-features = nix-command flakes
```

### 4. Home-Managerの適用

```bash
cd ~/dots
nix flake update
nix run home-manager/master -- switch --flake ~/dots#bido
```

これで、すべての設定（CLI、デスクトップ環境、アプリケーション等）が自動的にインストール・設定されます！

**注意:** 初回は多くのパッケージをダウンロード・ビルドするため、30分〜1時間程度かかる場合があります。

---

## 使い方

### 初回セットアップ

1. **Nixのインストール（まだの場合）:**
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

2. **Flakesの有効化:**

   `~/.config/nix/nix.conf` または `/etc/nix/nix.conf` に追加:
   ```
   experimental-features = nix-command flakes
   ```

3. **flake.lockの生成:**
   ```bash
   cd ~/dots
   nix flake update
   ```

4. **Home-Managerの適用:**
   ```bash
   nix run home-manager/master -- switch --flake ~/dots#bido
   ```

### 日常的な更新

**設定を変更した後:**
```bash
home-manager switch --flake ~/dots#bido
```

**パッケージを更新:**
```bash
cd ~/dots
nix flake update
home-manager switch --flake ~/dots#bido
```

### 現在のセットアップとの共存

このフェーズでは、以下のように共存できます：

- **Fish:** 既存の `~/.config/fish/config.fish` は残したまま、新しい設定をテスト可能
- **Alacritty:** Home-Manager版とcargoインストール版を併用可能
- **その他CLIツール:** pacman/cargo版とNix版が共存（PATHの順序で優先度決定）

### トラブルシューティング

**問題: コマンドが見つからない**
```bash
# Home-ManagerのPATHを確認
echo $PATH | tr ':' '\n' | grep nix

# Home-Managerを再適用
home-manager switch --flake ~/dots#bido
```

**問題: 設定が反映されない**
```bash
# シェルをリロード
exec fish

# または完全にログインし直す
```

## 次のPhase

- [x] Phase 1: CLIツール・基本設定
- [x] Phase 2A: 開発環境
- [x] Phase 2B: WMツール
- [x] Phase 3: デスクトップ環境
- [x] Phase 4: システムサービス
- [x] Phase 5: アプリケーション・テーマ
- [x] Phase 6: NixOS完全移行準備 ✅

## 参考リンク

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)
