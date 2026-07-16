{ config, pkgs, inputs, ... }:

{
  programs.emacs = {
    enable = true;
    # emacs30-pgtk: ネイティブ Wayland 対応 + tree-sitter 有効
    package = pkgs.emacs30-pgtk;

    extraPackages = epkgs: with epkgs; [
      # tree-sitter grammars（全言語分を一括提供）
      treesit-grammars.with-all-grammars
      # typst は with-all-grammars に含まれない場合があるため明示的に追加
      (treesit-grammars.with-grammars (g: [ g.tree-sitter-typst ]))

      use-package
      magit
      which-key
      vertico
      orderless
      consult
      corfu
      corfu-terminal
      cape
      treesit-auto
      rainbow-delimiters
      doom-themes
      doom-modeline
      nerd-icons
      nix-ts-mode
      zig-mode
      svelte-mode
      qml-mode
      markdown-mode
      obsidian
      calfw
      yasnippet
      yasnippet-snippets
      undo-tree
      flycheck
      flycheck-rust
      multiple-cursors
      drag-stuff
      typst-ts-mode
      nyan-mode
      dimmer
      beacon
      swiper
      ace-window
      fish-mode
      cuda-mode
      cython-mode
      scss-mode
      csv-mode
    ];
  };

  # -nw モードのクリップボード連携に必要
  # LSP サーバー各種
  home.packages = with pkgs; [
    wl-clipboard

    # Rust: rust-analyzer は rustup が提供するため除外

    # Zig
    zls

    # Nix
    nil

    # JavaScript / TypeScript
    typescript-language-server

    # HTML / CSS / JSON（vscode-langservers-extracted に含まれる）
    vscode-langservers-extracted

    # Python
    pyright

    # Bash / Shell
    bash-language-server

    # Go
    gopls

    # Svelte
    svelte-language-server

    # TOML
    taplo

    # YAML
    yaml-language-server

    # Markdown
    marksman

    # Typst
    tinymist
  ];

  # Emacs daemon（systemd user service）
  services.emacs = {
    enable = true;
    package = config.programs.emacs.finalPackage;
    defaultEditor = false;         # EDITOR は下記で -c フラグ付きに手動設定
    startWithUserSession = true;  # default.target 依存（graphical-session.target は Hyprland で未起動）
  };

  # EDITOR: ターミナル内で開く（gh/git 等の CLI ツール向け; -nw = no window）
  # VISUAL: GUI フレームを新規作成（ファイルマネージャ等の GUI アプリ向け; -c）
  # gh は GH_EDITOR → VISUAL → EDITOR の順に参照するため GH_EDITOR で明示上書き
  # -a "" はクォートが hm-session-vars.sh で壊れるため省略（daemon は systemd で常時起動）
  home.sessionVariables = {
    EDITOR = "emacsclient -nw";
    VISUAL = "emacsclient -c";
    GH_EDITOR = "emacsclient -nw";
  };

  systemd.user.sessionVariables = {
    EDITOR = "emacsclient -nw";
    VISUAL = "emacsclient -c";
    GH_EDITOR = "emacsclient -nw";
  };

  # シンボリックリンク（nix store外の実パスを参照）にすることで、init.el 編集時にrebuild不要にする
  home.file.".emacs.d/init.el".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/config/emacs/init.el";

  xdg.desktopEntries.emacs = {
    name = "Emacs";
    genericName = "Text Editor";
    comment = "Edit text";
    # daemon が起動済みならそこに接続、未起動なら daemon を立ち上げて接続
    exec = "${config.programs.emacs.finalPackage}/bin/emacsclient -c -a \"\" %F";
    icon = "emacs";
    categories = [ "Development" "TextEditor" ];
    mimeType = [
      "text/english"
      "text/plain"
      "text/x-makefile"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-csrc"
      "text/x-java"
      "text/x-moc"
      "text/x-pascal"
      "text/x-tcl"
      "text/x-tex"
      "application/x-shellscript"
      "text/x-c"
      "text/x-c++"
    ];
  };
}
