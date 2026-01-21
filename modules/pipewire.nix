{ config, pkgs, ... }:

{
  # Pipewire オーディオサーバー
  # Home-Managerでユーザーレベルのサービスとして管理
  services.pipewire = {
    enable = true;

    # PulseAudio互換レイヤー
    pulse.enable = true;

    # ALSA統合
    alsa = {
      enable = true;
      support32Bit = true;
    };

    # JACK統合
    jack.enable = true;

    # Wireplumber（セッションマネージャー）
    wireplumber.enable = true;
  };

  # オーディオツール
  home.packages = with pkgs; [
    # GUIツール
    pavucontrol    # PulseAudio Volume Control
    qpwgraph       # Pipewire グラフエディタ
    helvum         # Pipewire パッチベイ

    # CLIツール
    pipewire
    wireplumber

    # 既にcli-tools.nixでインストール済みのものはコメントアウト
  ];
}
