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
    pulseaudio     # pactl のみ目的 (daemonは services.pulseaudio.enable = false で無効)
                   # quickshell の AudioService.qml が pactl subscribe でsink/source変化を監視

    # 既にcli-tools.nixでインストール済みのものはコメントアウト
  ];
}
