{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # ============================================================
    # Aliases
    # ============================================================
    shellAliases = {
      # Basic utilities
      less = "less -Q -R";
      wcopy = "wl-copy";
      wpaste="wl-paste --type 'text/plain;charset=utf-8'";

      # eza (ls replacement)
      ls = "eza";
      l = "ls";
      l1 = "eza -1";
      la = "eza -a";
      ll = "eza -l -h -@ -m --time-style=iso";
      lla = "eza -lh@ma --time-style=iso";
      lal = "eza -lh@ma --time-style=iso";

      # Other tools
      #z = "zoxide";
      dust = "dust -r";
      oc = "obsidian-cli";

      # Directory navigation
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......." = "cd ../../../../..";

      # translate-shell via docker
      trans = "docker run -it soimort/translate-shell -shell";

      # wget without history file
      wget = "wget --no-hsts";

      # claude-code
      claude = "bunx @anthropic-ai/claude-code";
    };

    # ============================================================
    # History configuration
    # ============================================================
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      share = true;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    # ============================================================
    # Completion system
    # ============================================================
    enableCompletion = true;

    # ============================================================
    # Shell options and initialization
    # ============================================================
    initContent = ''
      # ============================================================
      # Environment variables
      # ============================================================
      export GO_HOME="$HOME/.go"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.deno/bin:$PATH"
      export PATH="$HOME/.moon/bin:$PATH"
      export PATH="$GO_HOME/bin:$PATH"

      # LD_LIBRARY_PATH
      export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"

      # Set LD_LIBRARY_PATH for Playwright
      if [[ ":$LD_LIBRARY_PATH:" != *":/home/bido/.local/lib/playwright:"* ]]; then
          export LD_LIBRARY_PATH="/home/bido/.local/lib/playwright:''${LD_LIBRARY_PATH}"
      fi

      # .envファイルがあればsource（秘密情報用）
      if [ -f ~/.env ]; then
        source ~/.env
      fi

      # ============================================================
      # Completion system
      # ============================================================
      # Add custom completion directory to fpath
      fpath+=~/.zfunc

      # Enable zsh completion system
      autoload -Uz compinit
      compinit

      # Fish-like completion behavior
      # Menu completion: TAB cycles through candidates immediately
      setopt MENU_COMPLETE        # Insert first match immediately, TAB to cycle
      setopt AUTO_LIST            # List choices on ambiguous completion
      unsetopt AUTO_MENU          # Disable auto menu (conflicts with MENU_COMPLETE)
      unsetopt LIST_AMBIGUOUS     # Show menu immediately

      # Case-insensitive completion (fish-like)
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

      # Partial completion support (e.g., cd /u/lo/b -> /usr/local/bin)
      zstyle ':completion:*' list-suffixes
      zstyle ':completion:*' expand prefix suffix

      # Color completion menu (similar to fish)
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # Tab and Shift-Tab for cycling through completions
      bindkey '^I' menu-complete              # TAB
      bindkey '^[[Z' reverse-menu-complete    # Shift-TAB

      # mcfly・Claude CodeなどのTUIアプリがkitty keyboard protocolを有効化したまま
      # 終了することがある（Ctrl+C等で異常終了した場合）。その状態ではCtrl+J等が
      # 生のCSI uシーケンスとして表示されるため、各プロンプト表示前にリセットする。
      _reset_kitty_keyboard() {
        printf '\e[<u'  # スタックからpop（有効化前の状態に戻す）
      }
      add-zsh-hook precmd _reset_kitty_keyboard

      # ============================================================
      # mise (runtime manager) - Home Managerにmiseモジュールがないため手動
      # ============================================================
      eval "$(mise activate zsh)"
      eval "$(mise activate zsh --shims)"

      # ============================================================
      # Custom functions
      # ============================================================
      greet() {
          gh grass --animate
      }

      fish_greeting() {
          fortune | cowsay -f ghostbusters
          figlet "Ghost Busters!"
          echo "🐟"
      }

      # ============================================================
      # External scripts
      # ============================================================
      if [ -f ~/.config/dots/installedPackages/autoAdd.sh ]; then
          bash ~/.config/dots/installedPackages/autoAdd.sh
      fi

      # ============================================================
      # Display greeting on shell start
      # ============================================================
      fortune | cowsay -f ghostbusters

      # ============================================================
      # Zsh plugins - autosuggestions color configuration
      # ============================================================
      # zsh-autosuggestions color (fish_color_autosuggestion: 969896)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#969896'
    '';

    # ============================================================
    # Zsh plugins
    # ============================================================
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.8.0";
          sha256 = "sha256-iJdWopZwHpSyYl5/FQXEW7gl/SrKaYDEtTH9cGP7iPo=";
        };
      }
    ];

    # ============================================================
    # Syntax highlighting
    # ============================================================
    syntaxHighlighting = {
      enable = true;
      styles = {
        # fish_color_command: c397d8 (purple/magenta)
        command = "fg=#c397d8";
        alias = "fg=#c397d8";
        builtin = "fg=#c397d8";
        function = "fg=#c397d8";
        precommand = "fg=#c397d8";

        # fish_color_param: 7aa6da (blue)
        arg0 = "fg=#c397d8";
        default = "fg=#7aa6da";
        unknown-token = "fg=#d54e53";

        # fish_color_quote: b9ca4a (green)
        single-quoted-argument = "fg=#b9ca4a";
        double-quoted-argument = "fg=#b9ca4a";
        dollar-quoted-argument = "fg=#b9ca4a";

        # fish_color_redirection: 70c0b1 (cyan)
        redirection = "fg=#70c0b1";

        # fish_color_operator: 00a6b2 (cyan)
        commandseparator = "fg=#00a6b2";

        # fish_color_comment: e7c547 (yellow)
        comment = "fg=#e7c547";

        # fish_color_valid_path: underline
        path = "fg=#7aa6da,underline";
        path_prefix = "fg=#7aa6da,underline";
        path_approx = "fg=#7aa6da,underline";

        # fish_color_escape: 00a6b2 (cyan)
        back-quoted-argument = "fg=#00a6b2";
        back-quoted-argument-delimiter = "fg=#00a6b2";
        single-hyphen-option = "fg=#7aa6da";
        double-hyphen-option = "fg=#7aa6da";

        # Globbing
        globbing = "fg=#7aa6da";
        history-expansion = "fg=#00a6b2";

        # Reserved words (if, then, else, etc.)
        reserved-word = "fg=#c397d8";

        # Assign
        assign = "fg=#7aa6da";
      };
    };
  };

  # ============================================================
  # Additional packages needed for zsh setup
  # ============================================================
  home.packages = with pkgs; [
    mise      # Runtime manager (Home Managerモジュールがないため)
    fortune   # For greeting
    cowsay    # For greeting
    figlet    # For greeting
  ];
  # zoxide, mcfly, gh は programs.* で管理されるため削除
}
