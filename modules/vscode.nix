{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    # VSCode設定
    userSettings = {
      # テーマ
      "workbench.colorTheme" = "Dracula At Night";
      "workbench.startupEditor" = "none";

      # エディタ設定
      "editor.minimap.enabled" = false;
      "editor.fontFamily" = "'Source Code Pro', 'monospace', monospace";
      "editor.fontSize" = 15;
      "editor.renderWhitespace" = "all";
      "editor.inlineSuggest.enabled" = true;

      # インデント設定
      "editor.detectIndentation" = false;
      "editor.insertSpaces" = false;  # Tab文字を使う
      "editor.tabSize" = 4;

      # YAML専用設定
      "[yaml]" = {
        "editor.insertSpaces" = true;  # YAMLはスペース
        "editor.tabSize" = 2;
      };

      # Rust設定
      "[rust]" = {};
      "rust-analyzer.server.path" = "~/.cargo/bin/rust-analyzer";

      # ターミナル
      "terminal.integrated.tabFocusMode" = true;

      # ウィンドウ
      "window.menuBarVisibility" = "hidden";
      "window.customMenuBarAltFocus" = false;

      # セキュリティ
      "security.workspace.trust.untrustedFiles" = "open";

      # カラーカスタマイズ
      "editor.tokenColorCustomizations" = {
        "comments" = "#1bc415";
      };

      # スペルチェック
      "cSpell.userWords" = [
        "bido"
        "chrono"
        "stylesheet"
      ];

      # Svelte
      "svelte.enable-ts-plugin" = true;

      # Markdown
      "markdown-pdf.breaks" = true;
      "markdown.preview.breaks" = true;

      # Diff
      "diffEditor.ignoreTrimWhitespace" = false;

      # その他
      "extensions.ignoreRecommendations" = true;

      # GitHub Copilot
      "github.copilot.nextEditSuggestions.enabled" = true;
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = true;
        "scminput" = false;
      };

      # Claude Code
      "claudeCode.preferredLocation" = "panel";

      # Office
      "vscode-office.openOutline" = false;
      "workbench.editorAssociations" = {
        "*.copilotmd" = "vscode.markdown.preview.editor";
        "*.pdf" = "cweijan.officeViewer";
      };

      # Run on Save (Typstファイルの自動変換)
      "emeraldwalk.runonsave" = {
        "commands" = [
          {
            "match" = ".*\\.typ$";
            "cmd" = "sed -i 's/、/,/g; s/。/./g' \${file}";
          }
        ];
      };
    };

    # 拡張機能（オプション: 必要に応じて追加）
    extensions = with pkgs.vscode-extensions; [
      # Rust
      rust-lang.rust-analyzer

      # GitHub
      github.copilot
      github.copilot-chat

      # テーマ
      dracula-theme.theme-dracula

      # 言語サポート
      # bungcip.better-toml  # TOML
      # tamasfe.even-better-toml  # TOML (better)

      # 必要に応じて他の拡張機能を追加
    ];
  };

  # VSCodeが依存するパッケージ
  home.packages = with pkgs; [
    # 既にcli-tools.nixでインストール済み
  ];
}
