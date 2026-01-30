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
    helvum         # Pipewire パッチベイ

    # CLIツール
    pulsemixer     # CLI audio mixer

    # 既にcli-tools.nixでインストール済みのものはコメントアウト
  ];
}
