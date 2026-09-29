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
      beep="play -n synth 0.3 sine 1000 > /dev/null 2>&1";

      # eza (ls replacement)
      ls = "eza";
      l = "ls";
      l1 = "eza -1";
      la = "eza -a";
      ll = "eza -l -h -@ -m --time-style=iso";
      lla = "eza -lh@ma --time-style=iso";
      lal = "eza -lh@ma --time-style=iso";

	  # rm
	  rm = "rm -I";

      # Other tools
      #z = "zoxide";
      dust = "dust -r";
      oc = "obsidian-cli";

      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......." = "cd ../../../../..";

      # translate-shell via docker
      trans = "docker run -it soimort/translate-shell -shell";

      # wget without history file
      wget = "wget --no-hsts";

	  # trashy(alternative of rm and trash-cli)
	  t = "trash";

      # claude-codeはnative-installerを使用

      # em は initContent の関数で定義（server 有無で切り替え）
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
    enableCompletion = false; # compinit を initContent で手動管理（fpath順序制御・キャッシュ化のため）

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

      # Playwright ライブラリパス（配置されている場合のみ追加）
      if [[ -d "$HOME/.local/lib/playwright" && ":$LD_LIBRARY_PATH:" != *":$HOME/.local/lib/playwright:"* ]]; then
          export LD_LIBRARY_PATH="$HOME/.local/lib/playwright''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}}"
      fi

      # .envファイルがあればsource（秘密情報用）
      if [ -f ~/.env ]; then
        source ~/.env
      fi

      # ============================================================
      # Completion system
      # ============================================================
      # compinit を最初のコマンド実行直前（preexec）まで遅延させて起動時間を短縮。
      # nixプロファイル更新時は tool_init キャッシュ再生成時に zcompdump を削除し、
      # 次の preexec で強制的にフル compinit が走る。
      fpath=(~/.zfunc $fpath)
      autoload -Uz compinit
      _deferred_compinit() {
        compinit -C
        add-zsh-hook -D preexec _deferred_compinit
      }
      add-zsh-hook preexec _deferred_compinit

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
      # Tool init cache
      # home-manager switch (NIX_PROFILES末尾) または nixos-rebuild (/run/current-system)
      # で更新されたときにキャッシュを再生成する
      # ============================================================
      () {
        local cache="$HOME/.cache/zsh/tool_init.zsh"
        local user_profile="''${NIX_PROFILES##* }"
        local system_profile="/run/current-system"
        if [[ ! -f "$cache" \
            || "$user_profile"   -nt "$cache" \
            || "$system_profile" -nt "$cache" ]]; then
          mkdir -p "''${cache:h}"
          {
            zoxide init zsh
            starship init zsh
            mcfly init zsh
            direnv hook zsh
            mise activate zsh --shims
          } > "$cache"
          rm -f ~/.zcompdump  # completion cache を強制更新（次回起動でフル compinit）
        fi
        source "$cache"
      }

      # ============================================================
      # Custom functions
      # ============================================================

      # Emacs: server が動いていれば emacsclient -t、なければ通常起動
      em() {
        emacsclient -t "$@" 2>/dev/null || emacs -nw "$@"
      }

      greet() {
          gh grass --animate
      }

      # ============================================================
      # Display greeting on shell start (対話セッションのみ)
      # ============================================================
      # -o interactive だけでは `zsh -i -c 'cmd'` でも真になり、zshを内部で叩く
      # ツールの stdout に AA が混入する。-c 指定時は ZSH_EXECUTION_STRING が
      # セットされるので、それで実セッションと区別する。
      [[ -o interactive && -z $ZSH_EXECUTION_STRING ]] && fortune | cowsay -f ghostbusters

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
  # Zsh completions (custom CLI tools)
  # ============================================================
  # twitter-cli 用のzsh補完。上流が補完を同梱していないため手書きし、
  # 約400行あるので静的ファイルとして分離している。
  home.file.".zfunc/_twitter".source = ./zsh-completions/_twitter;

  # ============================================================
  # Additional packages needed for zsh setup
  # ============================================================
  home.packages = with pkgs; [
    # cowsay は cowsay.nix で管理（COWPATH 設定と同居させる）
    figlet    # ASCIIアートテキスト生成
    sox       # beep エイリアス (play -n synth) が使用
  ];
  # zoxide, mcfly, gh は programs.* で管理されるため削除
}
