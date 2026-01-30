{ config, pkgs, ... }:

{
  # 高優先度アプリケーション

  home.packages = with pkgs; [
    # ============
    # ブラウザ
    # ============
    firefox

    # ============
    # 生産性
    # ============
    # obsidian                  # ノートアプリ（ネットワークエラーのため一時無効化）

    # ============
    # メディアプレーヤー
    # ============
    mpv                         # ビデオプレーヤー
    feh                         # 画像ビューア

    # ============
    # 動画編集
    # ============
    kdePackages.kdenlive        # 動画編集ソフト

    # ============
    # ダウンローダー
    # ============
    yt-dlp                      # YouTube等のダウンロード
    aria2                       # 高速ダウンローダー

    # ============
    # コンテナ
    # ============
    podman                      # コンテナランタイム
    podman-compose              # docker-compose互換
    # podman-dockerは別途設定が必要

    # ============
    # ファイルマネージャ
    # ============
    kdePackages.dolphin         # KDEファイルマネージャ
    nautilus                    # GNOMEファイルマネージャ
    gvfs                        # Nautilus用仮想ファイルシステム

    # ============
    # コミュニケーション
    # ============
    discord                     # Discord
    # thunderbird              # メール（必要な場合）

    # ============
    # ユーティリティ
    # ============
    rsync                       # ファイル同期
    transmission_4-gtk          # Torrentクライアント（GUI）
    gparted                     # パーティション管理

    # ============
    # ネットワークツール
    # ============
    nmap                        # ネットワークスキャン
    cloudflared                 # Cloudflare Tunnel

    # ============
    # 録画・スクリーンショット
    # ============
    # obs-studio                # 配信・録画（必要な場合）
    kazam                       # スクリーン録画
    simplescreenrecorder        # スクリーン録画

    # ============
    # その他ツール
    # ============
    # obsidian-cli              # Obsidian CLI（Nixpkgsに存在しない）
  ];

  # Firefox設定（オプション）
  programs.firefox = {
    enable = true;
    # profiles = {
    #   default = {
    #     id = 0;
    #     name = "default";
    #     isDefault = true;
    #   };
    # };
  };

  # mpv設定
  programs.mpv = {
    enable = true;
    config = {
      # 基本設定
      vo = "gpu";
      hwdec = "auto";

      # 字幕
      sub-auto = "fuzzy";

      # その他
      keep-open = "yes";
    };
  };

  # Podman設定
  # 注意: podman-dockerのエイリアスはsystemdサービスで設定する必要があります
  # Home-Managerでは限定的なサポート
  home.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };
}
