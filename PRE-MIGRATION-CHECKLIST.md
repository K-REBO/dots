# 移行前チェックリスト

NixOSへの移行を開始する前に、このチェックリストを確認してください。

## 📋 移行前の準備

### ✅ バックアップ（必須）

- [ ] **ホームディレクトリ全体**をバックアップ
  ```bash
  rsync -aAXv /home/bido/ /path/to/backup/home-bido/
  ```

- [ ] **dots設定**をバックアップ（または Gitにpush）
  ```bash
  cd ~/dots
  git add .
  git commit -m "Pre-migration backup"
  git push
  ```

- [ ] **重要なプロジェクト**をバックアップ
  ```bash
  rsync -av ~/projects/ /path/to/backup/projects/
  ```

- [ ] **SSH鍵・GPG鍵**をバックアップ
  ```bash
  rsync -av ~/.ssh/ /path/to/backup/ssh/
  rsync -av ~/.gnupg/ /path/to/backup/gnupg/
  ```

- [ ] **ブラウザプロファイル**をエクスポート
  - Firefoxのブックマーク・拡張機能リスト
  - ログイン情報（パスワードマネージャーで管理）

- [ ] **Obsidian vault**などのドキュメント
  ```bash
  rsync -av ~/Documents/ /path/to/backup/Documents/
  ```

### ✅ システム情報の記録

- [ ] **パーティション情報**を記録
  ```bash
  lsblk -f > ~/partition-info.txt
  sudo fdisk -l > ~/fdisk-info.txt
  ```

- [ ] **ネットワーク設定**を記録
  ```bash
  nmcli connection show > ~/network-connections.txt
  ip addr > ~/network-interfaces.txt
  ```

- [ ] **ハードウェア情報**を記録
  ```bash
  lspci > ~/hardware-pci.txt
  lsusb > ~/hardware-usb.txt
  ```

### ✅ 設定ファイルの確認

- [ ] `~/dots/` ディレクトリが完全であることを確認
  ```bash
  cd ~/dots
  ls -la flake.nix home.nix configuration.nix
  ls -la modules/
  echo "モジュール数: $(ls -1 modules/*.nix | wc -l)"
  # 期待値: 18モジュール
  ```

- [ ] すべての設定ファイルが正しく配置されている
  - [ ] flake.nix
  - [ ] home.nix
  - [ ] configuration.nix
  - [ ] nixos-reference.nix
  - [ ] modules/ (18ファイル)
  - [ ] README.md
  - [ ] INSTALLATION-GUIDE.md

### ✅ 外部依存の確認

- [ ] **クラウド同期**が完了している
  - Obsidian
  - その他のクラウドサービス

- [ ] **Gitリポジトリ**がすべてプッシュされている
  ```bash
  cd ~/projects
  for d in */; do
    echo "=== $d ==="
    cd "$d"
    git status
    cd ..
  done
  ```

- [ ] **重要なメール**がダウンロードされている（ローカル保存する場合）

### ✅ ハードウェア準備

- [ ] **NixOS ISO USBメディア**を作成済み
  - ISOをダウンロード
  - USBに書き込み
  - 起動確認（オプション）

- [ ] **リカバリUSB**を準備（Arch Linux Live USB等）

- [ ] **外付けストレージ**を準備（バックアップ用）
  - 容量: 最低でもホームディレクトリサイズの2倍
  - 接続確認

### ✅ インストールメディア

- [ ] **NixOS 24.11 ISO**をダウンロード
  - https://nixos.org/download.html
  - GNOME版を推奨（GUIで作業しやすい）

- [ ] **チェックサム確認**
  ```bash
  sha256sum nixos-*.iso
  # 公式サイトのチェックサムと比較
  ```

### ✅ ネットワーク確認

- [ ] **有線LANケーブル**を準備（WiFi設定前に使用）
- [ ] **WiFiパスワード**を確認・記録
- [ ] **インターネット接続**が安定している

### ✅ 時間の確保

- [ ] **2-4時間の作業時間**を確保
- [ ] 中断されない環境を確保
- [ ] バッテリー切れに注意（ラップトップの場合は充電）

---

## 📦 移行するデータ・設定の最終確認

### ユーザーデータ

- [ ] ドキュメント: `~/Documents/`
- [ ] ダウンロード: `~/Downloads/`
- [ ] ピクチャ: `~/Pictures/`
- [ ] ビデオ: `~/Videos/`
- [ ] 音楽: `~/Music/`

### 開発環境

- [ ] プロジェクト: `~/projects/`
- [ ] Gitリポジトリ
- [ ] SSH鍵: `~/.ssh/`
- [ ] GPG鍵: `~/.gnupg/`

### アプリケーション設定

- [ ] Obsidian vault
- [ ] VSCode設定（dotfilesで管理済み）
- [ ] ブラウザプロファイル
- [ ] その他のアプリ設定

### システム設定（NixOSで再設定）

- [ ] ネットワーク接続
- [ ] Bluetooth設定
- [ ] ディスプレイ設定
- [ ] キーボード設定

---

## ⚠️ リスク確認

### データ損失のリスク

- [ ] **すべての重要データをバックアップした**ことを確認
- [ ] バックアップが**正常に読み取れる**ことを確認
- [ ] バックアップを**複数の場所**に保存（外付けHDD + クラウド等）

### ダウンタイム

- [ ] 作業中は**PCが使用できない**ことを理解
- [ ] 緊急時の**代替デバイス**がある（スマホ・別PC等）

### トラブル対応

- [ ] **リカバリUSB**で起動できることを確認済み
- [ ] **INSTALLATION-GUIDE.md**を別デバイスで参照可能
  - スマホ・タブレットで開く
  - または印刷する

---

## 🎯 最終確認

すべてのチェックが完了したら、以下を実行：

```bash
# バックアップの最終確認
ls -lh /path/to/backup/

# dots設定の最終確認
cd ~/dots
git status
git log -1

# システム情報の最終保存
date > ~/migration-date.txt
uname -a >> ~/migration-date.txt
```

---

## ✅ 準備完了！

すべてのチェックボックスにチェックが入ったら、移行を開始できます。

**次のステップ:**
1. `INSTALLATION-GUIDE.md`を参照
2. NixOS ISOから起動
3. インストール手順に従う

**頑張ってください！** 🚀
