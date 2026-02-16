{ config, pkgs, ... }:

{
  # 高優先度アプリケーション

  home.packages = with pkgs; [
    # ============
    # ブラウザ
    # ============
    # firefox  # programs.firefox.enableで管理

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
    # 音楽制作
    # ============
    bitwig-studio               # DAW

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
    wf-recorder                 # Waylandスクリーン録画（Shift+Print）

    # ============
    # その他ツール
    # ============
    # obsidian-cli              # Obsidian CLI（Nixpkgsに存在しない）
  ];

  # Firefox設定
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;

      # 拡張機能はFirefox Syncで管理

      # 検索エンジン
      search = {
        default = "Google";
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Options" = {
            urls = [{
              template = "https://search.nixos.org/options";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };
          "GitHub" = {
            urls = [{ template = "https://github.com/search?q={searchTerms}"; }];
            definedAliases = [ "@gh" ];
          };
          "YouTube" = {
            urls = [{ template = "https://www.youtube.com/results?search_query={searchTerms}"; }];
            definedAliases = [ "@yt" ];
          };
        };
      };

      # about:config設定
      settings = {
        # プライバシー
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;

        # UI
        "browser.tabs.loadInBackground" = true;
        "browser.urlbar.suggest.searches" = true;
        "browser.download.useDownloadDir" = false;  # 常にダウンロード場所を確認

        # パフォーマンス
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;  # ハードウェアアクセラレーション

        # 新しいタブ
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # その他
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.pocket.enabled" = false;

        # 日本語
        "intl.accept_languages" = "ja,en-US,en";
      };
    };
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
