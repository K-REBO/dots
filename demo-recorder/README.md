# Hyprland Demo VM

*Reproducible Desktop Demo Video Generator*

## Overview

ホストPCのデスクトップ環境を NixOS QEMU VM 上で再現し、決定論的なデモ動画を生成するシステム。

* ホストと同一のテーマ/壁紙/フォント/設定を使用
* ステートレスな QEMU VM で毎回クリーンな状態から起動
* `~/vm-recordings/demo.mp4` にホスト側へ自動保存
* ホスト Nix ストアを 9p virtfs で共有 → パッケージ再ダウンロード不要

---

## Quick Start

```bash
# VM ビルド
nix build .#nixosConfigurations.demo-vm.config.system.build.vm

# 録画実行 (~/vm-recordings/demo.mp4 に保存)
rm -f demo-vm.qcow2
DEMO_DIR="$(pwd)/demo-recorder/demos" ./result/bin/run-demo-vm-vm
```

デモスクリプトは `DEMO_DIR` 内の `demo.json` を自動で読み込む。

---

## Architecture

```
Host (NixOS)
 ├─ flake.nix  (host + demo-vm の両定義)
 ├─ /nix/store (read-only, 9p でVM共有)
 ├─ ~/vm-recordings/  (録画出力先)
 └─ QEMU VM
     ├─ demo-vm.qcow2  (ephemeral, 実行毎に削除)
     ├─ Hyprland (headless, WLR_BACKENDS=headless WLR_RENDERER=gles2)
     ├─ swaybg  (壁紙表示, GPU不要)
     ├─ eww     (ステータスバー)
     ├─ alacritty × 3 (zsh + starship, dwindle レイアウト)
     ├─ demo-runner  (録画制御 systemd exec-once)
     ├─ replay-engine  (demo.json 実行)
     └─ wf-recorder  (動画キャプチャ)
```

---

## Demo Script Format

`demos/demo.json` に JSON 配列でアクションを記述する。

```json
[
  { "comment": "説明文 (スキップされる)" },
  { "wait": 2.5 },
  { "exec": "alacritty" },
  { "type": "nix run nixpkgs#neofetch\n" },
  { "dispatch": "togglesplit" },
  { "workspace": 2 },
  { "move": [0.5, 0.5] },
  { "click": 1 },
  { "key": "SUPER+RETURN" }
]
```

| アクション | 説明 |
|-----------|------|
| `wait` | 秒数待機 |
| `exec` | `hyprctl dispatch exec` でアプリ起動 |
| `type` | クリップボード経由でテキスト入力 (`\n` で実行) |
| `dispatch` | `hyprctl dispatch` 任意コマンド |
| `workspace` | ワークスペース切替 |
| `move` | マウス移動 (0.0–1.0 相対座標) |
| `click` | マウスクリック (1=左, 2=中, 3=右) |
| `key` | キー送信 (例: `SUPER+RETURN`, `CTRL+C`) |
| `layout` | 事前定義レイアウト適用 |

### テキスト入力の仕組み

Wayland + Hyprland 環境では `wtype` に文字化けバグがあるため、
クリップボード経由でペーストする方式を採用:

```
wl-copy -- "text\n"  &
wtype -M ctrl -M shift -k v -m shift -m ctrl
```

zsh の bracketed paste は `.zshrc` で `unset zle_bracketed_paste` により無効化済み。

---

## VM 構成の詳細

### シェル & プロンプト

* **zsh 5.9** + **starship** (実機と同一の `starship.toml`)
* `nix run nixpkgs#neofetch` は `.zshrc` のラッパー経由で `fastfetch` を呼び出す
  (neofetch は nixpkgs から削除済みのため)

### レンダリング

| 設定 | 値 | 理由 |
|------|-----|------|
| `WLR_BACKENDS` | `headless` | 物理ディスプレイ不要 |
| `WLR_RENDERER` | `gles2` | XWayland + wmfocus の EGL 対応 |
| `LIBGL_ALWAYS_SOFTWARE` | `1` | Mesa ソフトウェアレンダリング |
| `GALLIUM_DRIVER` | `llvmpipe` | EGL サポートあり (softpipe は不可) |
| `hardware.graphics.enable` | `true` | VM 内で Mesa/EGL を有効化 |

### wmfocus のビルド

wmfocus は Hyprland の wlr_foreign_toplevel プロトコルを使うため、
`cargoExtraArgs = "--features hyprland"` でビルドが必要。

```nix
commonArgs = {
  src = wmfocus-src;
  cargoExtraArgs = "--features hyprland";
  nativeBuildInputs = with final; [ pkg-config cmake autoPatchelfHook ];
  buildInputs = with final; [ cairo libxcb libx11 fontconfig wayland libxkbcommon expat freetype ];
};
```

`buildFeatures = [ "hyprland" ]` は crane では無視されるため不可。
`autoPatchelfHook` がないと RUNPATH が空になりランタイムエラー発生。

### vicinae

Hyprland 起動時に `exec-once = vicinae server` でデーモン起動が必要。
その後 `vicinae toggle` でランチャーを開閉できる。

---

## デモシーケンス (demos/demo.json)

```
0s   壁紙 + Ewwバー表示
5s   alacritty #1 起動 → nix run nixpkgs#neofetch (fastfetch)
13s  alacritty #2 起動 (右分割)
16s  alacritty #3 起動 (右下分割)
18s  pastel list でカラーパレット表示
22s  wmfocus でウィンドウ選択UI (timeout 4s で自動終了)
28s  vicinae ランチャーを開く
33s  vicinae を閉じる
35s  録画終了
```

---

## ログファイル

VM 実行後、`~/vm-recordings/` に以下が生成される:

| ファイル | 内容 |
|---------|------|
| `demo.mp4` | 録画動画 |
| `demo-runner.log` | 録画制御ログ |
| `replay-engine.log` | デモスクリプト実行ログ |
| `hyprland.log` | Hyprland ログ |
