{ config, pkgs, ... }:

{
  # Pipewire オーディオサーバー
  # 注意: Pipewireのサービス設定はNixOSシステムレベル（configuration.nix）で行う必要があります
  # ここではオーディオ関連のユーザーツールのみをインストールします

  # オーディオツール
  home.packages = with pkgs; [
    # GUIツール
    pavucontrol    # PulseAudio Volume Control
    qpwgraph       # Pipewire グラフエディタ
    crosspipe      # Pipewire パッチベイ (helvumの代替)

    # CLIツール
    pulsemixer     # CLI audio mixer

    # 既にcli-tools.nixでインストール済みのものはコメントアウト
  ];
}
