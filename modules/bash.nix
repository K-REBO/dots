{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # Bash prompt (PS1)
    bashrcExtra = ''
      # カスタムプロンプト
      if [ $UID -eq 0 ]; then
          PS1="\[\033[31m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
      else
          PS1="\[\033[36m\]\u@\h\[\033[00m\]:\[\033[01m\]\w\[\033[00m\]\\$ "
      fi

      # PATH設定
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.deno/bin:$PATH"
      export PATH="$HOME/.moon/bin:$PATH"
      export GO_HOME="$HOME/.go"
      export PATH="$GO_HOME/bin:$PATH"

      # LD_LIBRARY_PATH
      export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"

      # .envファイルがあればsource（秘密情報用）
      if [ -f ~/.env ]; then
        source ~/.env
      fi

      # zoxide初期化
      eval "$(zoxide init bash)"

      # mcfly初期化
      eval "$(mcfly init bash)"

      # GitHub CLI補完
      eval "$(gh completion -s bash)"

      # Fishシェルを起動（bashから自動的にfishへ移行）
      # 注意: この行をコメントアウトすると、bashのまま起動します
      if command -v fish &> /dev/null; then
        exec fish
      fi
    '';

    shellAliases = {
      # 基本
      ls = "ls --color=auto";
      wget = "wget --no-hsts";
      less = "less -Q";

      # eza (ls代替)
      l = "ls";
      l1 = "eza -1";
      la = "eza -a";
      ll = "eza -l -h -@ -m --time-style=iso";
      lla = "eza -lh@ma --time-style=iso";
      lal = "eza -lh@ma --time-style=iso";

      # ツール
      z = "zoxide";
      dust = "dust -r";
      wcopy = "wl-copy";
      wpaste = "wl-paste";
      oc = "obsidian-cli";

      # ディレクトリ移動
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......." = "cd ../../../../..";
    };

    # 履歴設定
    historySize = 10000;
    historyFileSize = 20000;
    historyControl = [ "ignoredups" "ignorespace" ];
  };

  # Cargo環境変数（bashrcから）
  home.sessionVariables = {
    GOPATH = "$HOME/.go";
  };
}
