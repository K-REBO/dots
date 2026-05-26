# dotfiles

NixOS + Home Manager で管理する個人用dotfiles

![demo](demo-recorder/demo.gif)

## Stack

- **OS**: NixOS (unstable)
- **WM**: Hyprland
- **Bar**: eww
- **Terminal**: Alacritty
- **Shell**: Zsh + Starship
- **Launcher**: vicinae
- **IME**: Fcitx5
- **Editor**: Emacs (emacs30-pgtk) / VSCode

## Structure

```
.
├── flake.nix              # Flake entry point
├── home.nix               # Home Manager entry point
├── config/                # Raw config files
│   ├── emacs/             # Emacs init.el
│   ├── eww/               # eww widgets & scripts
│   ├── fcitx5/            # Fcitx5 settings
│   ├── hypr/              # Hyprland config, wallpapers & scripts
│   ├── vicinae/           # vicinae launcher config
│   ├── xremap/            # Key remapping
│   └── quickshell/        # quickshell widgets
├── modules/
│   ├── home/              # Home Manager modules
│   │   ├── alacritty.nix
│   │   ├── applications.nix
│   │   ├── cli-tools.nix
│   │   ├── emacs.nix
│   │   ├── eww.nix
│   │   ├── fcitx5.nix
│   │   ├── fonts.nix
│   │   ├── git.nix
│   │   ├── hyprland.nix
│   │   ├── language-tools.nix
│   │   ├── shell.nix
│   │   ├── themes.nix
│   │   ├── vscode.nix
│   │   ├── vicinae.nix
│   │   ├── zsh.nix
│   │   └── ...
│   └── nixos/             # NixOS modules
├── hosts/
│   └── nixos/             # Host-specific config
├── demo-recorder/         # 再現性のあるデモGIF生成ツール
│   ├── demos/             # デモスクリプト (JSON)
│   ├── nix/               # VM設定
│   ├── scripts/           # replay-engine, make-gif, run-demo
│   └── wm/hyprland/       # WM別設定
└── secrets/               # Encrypted secrets (agenix)
```

## eww Bar

Tokyo Night テーマの水平トップバー。全ウィジェットをスクラッチで自作。

### Bar ウィジェット一覧

| ウィジェット | 説明 |
|---|---|
| **Power Menu** | NixOSアイコン、ホバーでShutdown/Reboot/Sleep/Lock/Logoutを展開 |
| **Workspaces** | Hyprland IPC をリッスンしてリアルタイム更新 |
| **Volume** | ホバーでスライダー展開、スクロールで音量調整、右クリックで出力デバイス切替ポップアップ |
| **WiFi** | SSID表示、ホバーで信号強度/IP/ゲートウェイを展開 |
| **Bluetooth** | クリックでデバイス一覧ポップアップ（接続/切断/バッテリー残量表示） |
| **Battery** | アイコン + 残量% + 残り時間 |
| **IME** | Fcitx5 トグル（右クリックでメニュー） |
| **Brightness** | ホバーでスライダー展開、スクロールで調整 |
| **Screen Recorder** | 録画中のみ表示されるインジケーター |
| **Taildrop** | ファイル転送中のみ表示、ファイル名とステータスをリアルタイム表示 |
| **DateTime** | 日付 + 時刻、ホバーでカレンダーポップアップ |

### スクリプト

`config/eww/scripts/` に各ウィジェット対応のシェルスクリプトを配置。イベント駆動のものは `deflisten` で常駐プロセスを使用し、ポーリングを最小化。

```
scripts/
├── battery     # バッテリー残量・状態・残り時間
├── bluetooth   # デバイス一覧・接続制御
├── brightness  # 輝度取得・設定・inotifyリッスン
├── ime         # Fcitx5 状態トグル
├── micmute     # マイクミュート状態
├── power       # 電源操作
├── recorder    # 録画状態監視
├── taildrop    # ファイル転送監視
├── volume      # 音量・出力デバイス制御
├── weather     # 天気情報
├── wifi        # WiFi状態・詳細情報
└── workspace   # Hyprland ワークスペース状態
```

## Emacs

`emacs30-pgtk` を使用（ネイティブ Wayland 対応 + tree-sitter 統合）。メインエディタとして使用するほか、Obsidian の frontend としても活用。

- **パッケージ**: `emacs30-pgtk`（pgtk = Pure GTK, Wayland ネイティブ）
- **設定**: `config/emacs/init.el`
- **Nix**: `modules/home/emacs.nix`
- tree-sitter grammars は `treesit-grammars.with-all-grammars` で一括管理

## Demo Recorder

QEMU VM 上で headless Hyprland を起動し、`demos/demo.json` に記述したアクションを自動実行して GIF を生成するサブツール。

```bash
# VM ビルド (初回のみ)
nix build .#nixosConfigurations.demo-vm.config.system.build.vm

# GIF 生成
./demo-recorder/scripts/run-demo
```

詳細は [demo-recorder/README.md](demo-recorder/README.md) を参照。

## Installation

### 新マシンでのセットアップ

**1. NixOSをインストール後、新マシンのSSHホスト鍵を確認**

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

**2. 現在のマシンで `secrets/secrets.nix` に新マシンの鍵を追加してre-key**

```bash
# secrets/secrets.nix に新マシンのホスト鍵を追加
cd ~/.config/nix/secrets
agenix -r
git add . && git commit -m "add new machine host key" && git push
```

**3. 新マシンでcloneしてrebuild**

```bash
# flakesを有効化（NixOSインストール直後）
export NIX_CONFIG="experimental-features = nix-command flakes"

git clone https://github.com/K-REBO/dotfiles ~/.config/nix
sudo nixos-rebuild switch --flake ~/.config/nix#nixos
```

> WiFiパスワードはagenixで管理しているため、初回rebuildまでは有線か手動でWiFi接続しておく。

### Standalone Home Manager

```bash
home-manager switch --flake .#bido
```

---

## 災害復旧（マシンが起動不能になった場合）

### 必要なバックアップ

| ファイル | 用途 |
|---|---|
| `~/.ssh/id_ed25519` | **必須** — agenixシークレットの復号に使用 |
| `~/.ssh/github` | GitHub SSH鍵（なければ再生成してGitHubに登録し直すだけ） |

`id_ed25519` さえあれば全シークレットを復号・再暗号化できる。

### 復旧手順

```bash
# 1. 新マシンにSSH鍵を復元
mkdir -p ~/.ssh
cp /backup/id_ed25519 ~/.ssh/
chmod 600 ~/.ssh/id_ed25519

# 2. dotsをclone
export NIX_CONFIG="experimental-features = nix-command flakes"
git clone https://github.com/K-REBO/dotfiles ~/.config/nix

# 3. 新マシンのホスト鍵でシークレットを再暗号化
cat /etc/ssh/ssh_host_ed25519_key.pub  # 新マシンの鍵を確認
# secrets/secrets.nix に追加
cd ~/.config/nix/secrets
agenix -r
git add . && git commit -m "add new machine host key" && git push

# 4. rebuild
sudo nixos-rebuild switch --flake ~/.config/nix#nixos
```

## 自作ツール

flake.nix から直接ビルドして取り込んでいる自作・カスタムツール群。

### 自作リポジトリ

| ツール | リポジトリ | 概要 |
|---|---|---|
| **wayland-fcitx5-indicator** | [K-REBO/wayland_fcitx5_indicator](https://github.com/K-REBO/wayland_fcitx5_indicator) | Wayland ネイティブの Fcitx5 状態インジケーター。Home Manager モジュールとして提供 |
| **tp-render** | [K-REBO/tp-render](https://github.com/K-REBO/tp-render) | Obsidian のテンプレートを展開する CLI ツール（Node.js）。Emacs の obsidian.el から呼び出して使用 |

### Fork

| ツール | フォーク元 | 変更点 |
|---|---|---|
| **hyprselect** | [K-REBO/hyprselect](https://github.com/K-REBO/hyprselect) | Hyprland サポートを追加。`Mod+i` でウィンドウにラベルを表示しキー入力でフォーカス。crane + fenix で Rust ビルド |
| **obsidian-vault-cli** | [K-REBO/obsidian-vault-cli](https://github.com/K-REBO/obsidian-vault-cli) | AI エージェント向け Obsidian LiveSync 対応の暗号化 vault CLI |

### カスタム Nix オーバーレイ

nixpkgs に存在しないパッケージを flake.nix 内のオーバーレイで自前パッケージング。

| パッケージ | ソース | 手法 |
|---|---|---|
| **Apple Color Emoji** | GitHub Release (TTF) | `stdenvNoCC.mkDerivation` でフォントをインストール |
| **twitter-cli** | PyPI wheel | `buildPythonApplication` + 非標準依存 `xclienttransaction` を手動ビルド |
| **gh-grass** | [koki-develop/gh-grass](https://github.com/koki-develop/gh-grass) | `buildGoModule` でソースからビルド。ターミナルに GitHub contribution グラフを表示 |

## Flake Inputs

- [nixpkgs](https://github.com/nixos/nixpkgs) (unstable)
- [home-manager](https://github.com/nix-community/home-manager)
- [agenix](https://github.com/ryantm/agenix) - Secret management
- [NUR](https://github.com/nix-community/NUR)
- [crane](https://github.com/ipetkov/crane) + [fenix](https://github.com/nix-community/fenix) - Rust builds
- [nix-index-database](https://github.com/Mic92/nix-index-database) - プリビルド済み nix-index DB
- [weathr](https://github.com/Veirt/weathr) - 天気予報 CLI
- [deploy-rs](https://github.com/serokell/deploy-rs) - Deployment
