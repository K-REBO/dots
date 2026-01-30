{ config, pkgs, ... }:

{
  # 言語ツール・ランタイム

  home.packages = with pkgs; [
    # Rust (rustupは既存のものを使用)
    # rust-analyzer  # VSCodeモジュールでインストール済み
    rustup

    # Python
    python3
    python3Packages.pip

    # Node.js / JavaScript
    nodejs
    # pnpm  # pacmanでインストール済み

    # Deno
    deno

    # Playwright (ブラウザ自動化)
    playwright-driver.browsers

    # Go
    go

    # その他の言語
    # julia  # pacmanでインストール済み

    # Common Lisp (pacmanでインストール済み)
    # sbcl
    # clisp
    # ecl

    # ビルドツール
    cmake
    gnumake
    pkg-config

    # C/C++
    # gccとclangは同時に入れると競合するため、clangのみ使用
     gcc
    #clang
    lldb
  ];

  # mise設定（既にshell.nixで初期化済み）
  # miseで管理されているツールは既存の設定を維持

  # Cargo config
  home.file.".cargo/config.toml".text = ''
    [alias]
    b = "build"
    bl = "build --release"

    c = "check"

    r = "run"
    rl = "run --release"

    s = "search"
    i = "install"

    up = "install-update"


    [build]
    jobs = 14
    rustc-wrapper = "${config.home.homeDirectory}/.cargo/bin/sccache"
  '';

  # 環境変数（既にbash.nixとshell.nixで設定済み）
  home.sessionVariables = {
    # Cargo
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";

    # Go
    GOPATH = "${config.home.homeDirectory}/.go";

    # Deno
    DENO_INSTALL = "${config.home.homeDirectory}/.deno";

    # Playwright
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
  };

  # PATH設定は各シェル設定で管理
}
