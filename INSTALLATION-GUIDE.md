# NixOS完全移行ガイド

このガイドは、現在のArch Linuxシステムから NixOS への完全移行手順を説明します。

## ⚠️ 重要な注意事項

1. **バックアップ必須**: 移行前に必ず重要なデータをバックアップしてください
2. **時間の確保**: 移行には2-4時間かかる可能性があります
3. **インターネット接続**: 安定したネットワーク接続が必要です
4. **リカバリUSB**: 何か問題が発生した場合に備えてArch LinuxのライブUSBを準備

---

## Phase 1: 移行前準備（Arch Linux上）

### 1.1 重要データのバックアップ

```bash
# ホームディレクトリのバックアップ
sudo rsync -aAXv /home/bido/ /path/to/backup/home-bido/

# 特に重要なディレクトリ
rsync -av ~/dots/ /path/to/backup/dots/
rsync -av ~/.config/ /path/to/backup/config/
rsync -av ~/projects/ /path/to/backup/projects/
rsync -av ~/.ssh/ /path/to/backup/ssh/
rsync -av ~/.gnupg/ /path/to/backup/gnupg/

# データベース・設定ファイル
rsync -av ~/.local/share/ /path/to/backup/local-share/
```

### 1.2 パーティション情報の確認

```bash
# 現在のパーティション構成を記録
lsblk -f > ~/partition-info.txt
sudo fdisk -l > ~/fdisk-info.txt
df -h > ~/disk-usage.txt

# UEFI/BIOSの確認
ls /sys/firmware/efi && echo "UEFI" || echo "BIOS"
```

### 1.3 現在のハードウェア情報を保存

```bash
# ハードウェア情報
lspci > ~/hardware-pci.txt
lsusb > ~/hardware-usb.txt
lsmod > ~/kernel-modules.txt

# ネットワーク設定
ip addr > ~/network-interfaces.txt
nmcli connection show > ~/network-connections.txt
```

### 1.4 dots設定の最終確認

```bash
cd ~/dots

# すべてのファイルが存在することを確認
ls -la flake.nix home.nix configuration.nix nixos-reference.nix
ls -la modules/

# ファイル数の確認
echo "モジュール数: $(ls -1 modules/*.nix | wc -l)"
```

---

## Phase 2: NixOSインストールメディアの準備

### 2.1 NixOS ISOのダウンロード

```bash
# 最新のNixOS ISO（GNOME版推奨）
# https://nixos.org/download.html からダウンロード

# または
wget https://channels.nixos.org/nixos-24.11/latest-nixos-gnome-x86_64-linux.iso
```

### 2.2 インストールUSBの作成

```bash
# USBドライブの確認（例: /dev/sdb）
lsblk

# ISOをUSBに書き込み（⚠️ デバイス名を確認！）
sudo dd if=latest-nixos-gnome-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
sudo sync
```

---

## Phase 3: パーティション計画

### 推奨パーティション構成

#### オプションA: 完全クリーンインストール（推奨）

```
/dev/nvme0n1
├── /dev/nvme0n1p1  512MB   EFI System Partition (FAT32)
├── /dev/nvme0n1p2  [残り]  NixOS Root (ext4 or btrfs)
└── (オプション) swap
```

#### オプションB: デュアルブート（Arch Linuxと共存）

```
既存のEFIパーティションを使用
新しいパーティションをNixOS用に作成
```

### パーティションサイズの目安

- **EFI**: 512MB（既存のものを使用可）
- **Root (/)**: 最低50GB、推奨100GB以上
- **Home (/home)**: 別パーティションにすることも可能
- **Swap**: RAM容量と同等（16GB RAM なら16GB swap）

---

## Phase 4: NixOSのインストール

### 4.1 NixOS ISOから起動

1. USBから起動
2. GNOMEデスクトップが起動するまで待つ
3. ターミナルを開く

### 4.2 パーティションの作成

```bash
# パーティション作成（例: 完全クリーンインストール）
sudo parted /dev/nvme0n1 -- mklabel gpt
sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/nvme0n1 -- set 1 esp on
sudo parted /dev/nvme0n1 -- mkpart primary 512MiB 100%

# フォーマット
sudo mkfs.fat -F 32 -n BOOT /dev/nvme0n1p1
sudo mkfs.ext4 -L nixos /dev/nvme0n1p2

# マウント
sudo mount /dev/disk/by-label/nixos /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot
```

### 4.3 NixOS設定ファイルの生成と配置

```bash
# ハードウェア設定を生成
sudo nixos-generate-config --root /mnt

# バックアップからdots設定を復元
# （外付けHDD、USBメモリ、またはgit cloneで）

# 方法1: 外部メディアから
sudo mkdir -p /mnt/home/bido/dots
sudo cp -r /path/to/backup/dots/* /mnt/home/bido/dots/

# 方法2: Gitから（ネットワーク接続がある場合）
# sudo mkdir -p /mnt/home/bido
# cd /mnt/home/bido
# sudo git clone https://github.com/yourusername/dots.git

# configuration.nixをコピー
sudo cp /mnt/home/bido/dots/configuration.nix /mnt/etc/nixos/
```

### 4.4 設定ファイルの編集

```bash
# 生成されたhardware-configuration.nixを確認
sudo nano /mnt/etc/nixos/hardware-configuration.nix

# configuration.nixを確認・編集
sudo nano /mnt/etc/nixos/configuration.nix

# 重要: インポート行が正しいことを確認
# imports = [ ./hardware-configuration.nix ];
```

### 4.5 NixOSのインストール実行

```bash
# インストール開始（30分-1時間かかる）
sudo nixos-install

# rootパスワードを設定するよう求められます
# プロンプトに従って設定

# インストール完了後、再起動
sudo reboot
```

---

## Phase 5: 初回起動後の設定

### 5.1 ユーザーパスワードの設定

```bash
# NixOSに初めてログイン後
sudo passwd bido
```

### 5.2 Home-Managerのセットアップ

```bash
# ホームディレクトリに移動
cd ~/dots

# Flakesが有効になっていることを確認（すでにconfiguration.nixで設定済み）

# flake.lockを生成
nix flake update

# Home-Managerを初回適用
nix run home-manager/master -- switch --flake ~/dots#bido

# または、システムパッケージとしてインストール済みの場合
home-manager switch --flake ~/dots#bido
```

### 5.3 設定の確認とトラブルシューティング

```bash
# サービスの状態確認
systemctl status NetworkManager
systemctl status bluetooth
systemctl --user status pipewire

# Hyprlandの起動
# GDMからログアウトして、Hyprlandを選択してログイン
```

---

## Phase 6: データの復元

### 6.1 ホームディレクトリの復元

```bash
# バックアップから重要なデータを復元
rsync -av /path/to/backup/projects/ ~/projects/
rsync -av /path/to/backup/ssh/ ~/.ssh/
rsync -av /path/to/backup/gnupg/ ~/.gnupg/

# SSH鍵のパーミッション修正
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

### 6.2 アプリケーション設定の復元

```bash
# Obsidian vaultなど
rsync -av /path/to/backup/Documents/ ~/Documents/

# ブラウザプロファイル（必要な場合）
# Firefoxは ~/.mozilla/ に保存される
```

**注意:** 壁紙やHyprland設定ファイルは既に `hyprland.nix` で以下のディレクトリが自動的にコピーされます：
- `~/.config/hypr/wallpapers/`（壁紙11ファイル）
- `~/.config/hypr/scripts/`（カスタムスクリプト）
- 各種設定ファイル（hyprland.conf, hypridle.conf, hyprlock.conf）

これらは Home-Manager 適用時に自動的に配置されるため、手動でコピーする必要はありません。

---

## Phase 7: 最終確認

### 7.1 動作確認チェックリスト

- [ ] ネットワーク接続（WiFi/有線）
- [ ] Bluetooth動作
- [ ] オーディオ（Pipewire）
- [ ] 日本語入力（fcitx5-mozc）
- [ ] ディスプレイ設定（解像度、マルチモニタ）
- [ ] Hyprlandキーバインド
- [ ] ブラウザ（Firefox）
- [ ] ファイルマネージャ（Dolphin）
- [ ] ターミナル（Alacritty）
- [ ] 開発環境（VSCode、Git、言語ツール）
- [ ] コンテナ（podman）

### 7.2 システムアップデート

```bash
# システム全体のアップデート
sudo nixos-rebuild switch --upgrade

# Home-Managerのアップデート
cd ~/dots
nix flake update
home-manager switch --flake ~/dots#bido
```

---

## トラブルシューティング

### 問題: Hyprlandが起動しない

```bash
# ログを確認
journalctl -xe
journalctl --user -u hyprland

# GDMからログインし直す
# または、TTYに切り替えて確認（Ctrl+Alt+F2）
```

### 問題: 日本語入力ができない

```bash
# fcitx5の状態確認
systemctl --user status fcitx5

# 環境変数の確認
echo $GTK_IM_MODULE
echo $QT_IM_MODULE

# fcitx5を再起動
systemctl --user restart fcitx5
```

### 問題: オーディオが出ない

```bash
# Pipewireの状態確認
systemctl --user status pipewire pipewire-pulse wireplumber

# オーディオデバイスの確認
pactl list sinks
wpctl status

# 再起動
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### 問題: 設定変更が反映されない

```bash
# configuration.nixを編集後
sudo nixos-rebuild switch

# home.nixやモジュールを編集後
home-manager switch --flake ~/dots#bido
```

---

## 移行後のメンテナンス

### 定期的なアップデート

```bash
# 週1回程度
cd ~/dots
nix flake update
home-manager switch --flake ~/dots#bido
sudo nixos-rebuild switch --upgrade
```

### ガベージコレクション

```bash
# 古い世代の削除（自動設定済みだが手動も可能）
sudo nix-collect-garbage -d
nix-collect-garbage -d
```

### 設定のバックアップ

```bash
# dots設定をGitで管理（推奨）
cd ~/dots
git add .
git commit -m "Update configuration"
git push
```

---

## サポート・参考リンク

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)

---

**移行完了おめでとうございます！** 🎉
