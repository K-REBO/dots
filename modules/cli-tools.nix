{ config, pkgs, ... }:

{
  # Phase 1: CLIツール
  home.packages = with pkgs; [
    # ファイル管理・表示
    bat           # catの代替（シンタックスハイライト）
    eza           # lsの代替
    dust          # duの代替（ディスク使用量）
    hexyl         # hexダンプ

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
    git-delta     # gitの差分表示
    jujutsu       # jj-cli: バージョン管理

    # ビルド・開発支援
    sccache       # コンパイラキャッシュ

    # ファイル操作
    kondo         # プロジェクトクリーナー
    miniserve     # HTTPファイルサーバー

    # ドキュメント
    typst         # typst-cli

    # ユーティリティ
    pastel        # カラーツール

    # ツールバージョン管理
    mise          # 言語バージョン管理
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
}
