# 未移行の設定項目

## ✅ 移行済み（Phase 1-4）

### Phase 1: 基本
- CLIツール（bat, eza, zoxide等）
- シェル（fish, bash, zsh）
- Git, Vim
- Alacritty

### Phase 2: 開発環境
- VSCode
- 言語ツール（Python, Node.js, Go, C/C++）
- rofi, wofi, polybar

### Phase 3: デスクトップ
- Hyprland + エコシステム
- fcitx5日本語入力

### Phase 4: システム
- Pipewire
- nixos-reference.nix（システムサービス参考）

---

## ❌ 未移行の項目

### カテゴリ1: デスクトップアプリケーション

**ブラウザ:**
- firefox ⭐ 重要
- zen-browser-bin

**コミュニケーション:**
- discord_arch_electron
- thunderbird-i18n-ja（メール）

**生産性:**
- obsidian ⭐ 重要（ノートアプリ）
- libreoffice-still-ja

**ファイルマネージャ:**
- nautilus（GNOME）
- dolphin（KDE）

### カテゴリ2: メディア・クリエイティブツール

**画像・動画:**
- gimp（画像編集）
- blender（3D）
- mpv ⭐（ビデオプレーヤー）
- feh（画像ビューア）

**DAW・オーディオ:**
- ardour
- reaper
- bitwig-studio
- lmms
- guitarix, carla, calf（プラグイン）
- sonic-visualiser
- mixxx

**録画・配信:**
- simplescreenrecorder
- obs-studio（もしあれば）
- kazam

### カテゴリ3: 開発ツール（詳細）

**エディタ:**
- emacs ⚠️（スキップ済み）
- glade（GUI designer）

**コンテナ・仮想化:**
- podman + podman-docker ⭐
- virtualbox

**ビルドツール:**
- arduino-cli（もしあれば）

### カテゴリ4: ユーティリティ

**ダウンローダー:**
- aria2
- yt-dlp ⭐

**ファイル操作:**
- rsync
- transmission-cli（torrent）

**システムツール:**
- gparted（パーティション管理）
- timeshift（バックアップツール？）

**ネットワーク:**
- nmap
- cloudflared
- vpnツール（openconnect, openvpn）

### カテゴリ5: ゲーム・エミュレータ

- lutris
- dolphin-emu
- steam（Flatpak?）

### カテゴリ6: フォント ✅ 移行済み

**fonts.nixで管理:**
- noto-fonts ⭐
- noto-fonts-cjk ⭐
- noto-fonts-emoji
- dejavu_fonts
- liberation_ttf
- nerdfonts (UbuntuMono, JetBrainsMono等) ⭐
- cantarell-fonts
- source-code-pro
- jetbrains-mono
- ipafont (日本語)
- font-awesome

### カテゴリ7: その他の設定

**tmux:**
- 設定ファイルが見つからなかった
- 使用している場合は要設定

**dunst（通知デーモン）:**
- Hyprlandで使用
- 設定ファイル確認が必要

**redshift/gammastep:**
- 画面色温度調整
- polybarで使用

**GTK/Qtテーマ:**
- arc-gtk-theme-eos
- dracula-theme等
- アイコンテーマ（papirus等）

---

## 優先順位別推奨事項

### 🔴 高優先度 ✅ 移行済み

**applications.nixで管理:**
1. ✅ **Firefox**（メインブラウザ）
2. ✅ **Obsidian**（ノートアプリ）
3. ✅ **mpv**（ビデオプレーヤー）
4. ✅ **podman/docker**（開発用）
5. ✅ **フォント**（fonts.nixで管理）
6. ✅ **yt-dlp**（動画ダウンロード）
7. ✅ **Dolphin**（ファイルマネージャ）
8. ✅ **Discord**
9. ✅ **aria2**（ダウンローダー）
10. ✅ **feh**（画像ビューア）

**themes.nixで管理:**
11. ✅ **GTK/Qtテーマ**（Dracula, Papirus）

### 🟡 中優先度

**除外（ユーザー指定）:**
- ❌ GIMP（除外）
- ❌ Blender（除外）
- ❌ Nautilus（除外）
- ❌ LibreOffice（除外）

**その他のツール（applications.nixに含む）:**
- ✅ rsync
- ✅ transmission-gtk
- ✅ gparted
- ✅ nmap
- ✅ cloudflared
- ✅ kazam, simplescreenrecorder

### 🟢 低優先度（除外）

**除外（ユーザー指定）:**
- ❌ Ardour（除外）
- ❌ Reaper（除外）
- ❌ Bitwig等DAW関連（除外）
- ❌ Lutris（除外）
- ❌ Dolphin-emu（除外）
- ❌ VirtualBox（除外）

---

## 次のステップ提案

### オプションA: 必要最小限
高優先度のみ移行して、すぐにテスト開始

### オプションB: 日常使用レベル
高＋中優先度を移行

### オプションC: 完全移行
すべてのアプリケーションを移行

どれを選びますか？
