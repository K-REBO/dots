{ config, pkgs, inputs, ... }:

{
  # Phase 1: CLIツール
  home.packages = with pkgs; [
    # ファイル管理・表示
    bat           # catの代替（シンタックスハイライト）
    eza           # lsの代替
    dust          # duの代替（ディスク使用量）
    hexyl         # hexダンプ
    duf           # duの代替 (直感的)
    fzf           # fuzzy finder

    # プロセス・システム情報
    procs         # psの代替

    # 検索・移動
    zoxide        # cdの代替（スマートジャンプ）

    # テキスト処理
    jq            # JSON処理

    # 開発ツール
    just          # コマンドランナー
    hyperfine     # ベンチマーク
    tealdeer      # tldr（簡易man）
    tokei         # コード統計

    # Git関連
    delta         # gitの差分表示
    jujutsu       # jj-cli: バージョン管理

    # ビルド・開発支援
    sccache       # コンパイラキャッシュ

    # ファイル操作
    kondo         # プロジェクトクリーナー
    miniserve     # HTTPファイルサーバー

    # ドキュメント
    typst         # typst-cli

    # ユーティリティ
    comma         # nixのパッケージを一時的に実行 (, コマンド)
    pastel        # カラーツール
    imagemagick   # 画像操作ツール

    # ツールバージョン管理
    mise          # 言語バージョン管理

    # LLM agent cliツール
    # claude-code  # bun経由でインストール
    gemini-cli

    # Bun (claude-code用)
    bun

    # ウィンドウフォーカス
    wmfocus

    # キー入力表示（Wayland）
    wshowkeys
  ] ++ [
    # Nix関連 (flake inputsから取得して競合を回避)
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager

    # 天気
    inputs.weathr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # batの設定
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  # ezaのエイリアスはshell.nixで設定

  # direnv（nix develop自動有効化）
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # キャッシュ機能付きのnix統合
  };

  # bun グローバルパッケージの設定
  home.sessionPath = [ "$HOME/.bun/bin" ];
  home.sessionVariables = {
    BUN_INSTALL = "$HOME/.bun";
  };
}
