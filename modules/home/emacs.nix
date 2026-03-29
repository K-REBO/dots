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
      markdown-mode
      yasnippet
      yasnippet-snippets
      undo-tree
      flycheck
      multiple-cursors
      drag-stuff
      typst-ts-mode
      nyan-mode
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
    nodePackages.svelte-language-server

    # TOML
    taplo

    # YAML
    yaml-language-server

    # Markdown
    marksman

    # Typst
    tinymist
  ];

  home.file.".emacs.d/init.el".source = ../../config/emacs/init.el;

  xdg.desktopEntries.emacs = {
    name = "Emacs";
    genericName = "Text Editor";
    comment = "Edit text";
    exec = "${config.programs.emacs.finalPackage}/bin/emacs %F";
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
