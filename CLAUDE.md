# Quickshell移行プロジェクト

このブランチ (`feat/quickshell-migration`) はewwバーをQuickshell (Qt6/QML) に置き換えるWIPブランチです。

## 元の指示

> quickshellの使い方を確認して、現在のewwをquickshellに置き換えます。
> ewwはコメントアウト等で隠すだけで良い。ファイルの削除は不要。
> https://github.com/caelestia-dots/shell この実装を参考にして。
> - バーは上にすること
> - ewwで実現している機能をquickshellで更に美しくすること
> - テーマ: Tokyo Night
> - 対象: トップバー + アプリランチャー（vicinae置き換え）+ ロック画面（hyprlock置き換え）
> - ワークスペース表示: アクティブのみ表示
> - デザインは caelestia-dots/shell のような洗練されたものにすること

## 現在の状態

### 実装済み
- `config/quickshell/` 以下にQMLファイル一式を作成
- `shell.qml` — ShellRootエントリーポイント (Bar + Launcher + Lock)
- `Theme.qml` — デザイントークン singleton
- `bar/Bar.qml` — フローティングトップバー（ピル型UI、シアン/ブルーのアクセント）
- `bar/Recorder.qml` — 録画中インジケーター
- `bar/Taildrop.qml` — Tailscaleファイル受信インジケーター
- `launcher/Launcher.qml` — アプリランチャー（.desktopファイル読み込み、キーボードナビ）
- `lock/Lock.qml` — ロック画面（WlSessionLock）
- `services/` 以下: AudioService, BatteryService, BrightnessService, ImeService, NetworkService, BluetoothService

### 既知の問題・TODO
- **デザインが不十分** — ユーザーから「絶望的にデザインが悪い」と指摘。caelestia-dotsスタイルを参考に大幅改善が必要。
  - 現状: シアンのNixOSピル、ブルーの時計ピル、半透明ピル群
  - 目標: caelestia-dots風の洗練されたビジュアル
- ロック画面のPAM認証未テスト
- Bluetoothサービス未テスト

## Quickshell 技術メモ

### API (0.3.0)
- `Hyprland.activeToplevel` (focusedClientではない)
- `HyprlandToplevel.wayland?.appId` (classではない)
- `HyprlandMonitor.activeWorkspace.id`
- `SystemClock.date` (timeではない)
- `ExclusionMode`: Normal / Ignore / Auto (Exclusiveは存在しない)
- `PanelWindow` / `FloatingWindow`: `implicitWidth/Height` を使う (width/heightは非推奨)
- JS テンプレートリテラル内でbash変数を使う場合は `\${var}` とエスケープ必要

### ファイル構成の注意
- 各ディレクトリに `qmldir` が必要（singletonは `singleton TypeName 1.0 File.qml` 形式）
- `~/.config/quickshell` → Nixストア → `/home/bido/.config/nix/config/quickshell` のシンボリックリンクで即時反映

### 起動・デバッグ
```bash
quickshell                        # 起動
qs ipc call launcher toggle       # ランチャートグル
qs ipc call lock activate         # ロック画面
pkill quickshell && quickshell    # 再起動
cat /run/user/1000/quickshell/by-id/*/log.qslog  # ログ確認
```

### 変更したNixファイル
- `home.nix`: eww.nix → quickshell.nix
- `modules/home/eww.nix`: パッケージをコメントアウト
- `modules/home/hyprland.nix`: exec-once, keybind変更
- `config/hypr/hypridle.conf`: hyprlock → qs ipc call lock activate
