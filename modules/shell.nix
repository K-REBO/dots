{ config, pkgs, ... }:

{
  # Fish shell
  programs.fish = {
    enable = true;

    shellAliases = {
      # 基本コマンド
      less = "less -R";
      wcopy = "wl-copy";
      wpaste = "wl-paste --type 'text/plain;charset=utf-8'";

      # eza (ls代替)
      ls = "eza";
      l = "ls";
      l1 = "eza -1";
      la = "eza -a";
      ll = "eza -l -h -@ -m --time-style=iso";
      lla = "eza -lh@ma --time-style=iso";
      lal = "eza -lh@ma --time-style=iso";

      # その他
      z = "zoxide";
      dust = "dust -r";

      # ディレクトリ移動
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......." = "cd ../../../../..";

      # ツール
      trans = "docker run -it soimort/translate-shell -shell";
      oc = "obsidian-cli";
    };

    interactiveShellInit = ''
      # zoxide初期化
      zoxide init fish | source

      # mcfly初期化
      mcfly init fish | source

      # GitHub CLI補完
      gh completion -s fish | source

      # mise初期化
      mise activate fish | source
      mise activate fish --shims | source

      # starship初期化
      starship init fish | source

      # 環境変数
      set -x GO_HOME "$HOME/.go"
      fish_add_path "$GO_HOME/bin"

      # Playwright用LD_LIBRARY_PATH
      if not contains /home/bido/.local/lib/playwright $LD_LIBRARY_PATH
          set -x LD_LIBRARY_PATH /home/bido/.local/lib/playwright $LD_LIBRARY_PATH
      end
    '';
  };

  # Starship (プロンプト)
  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$all\n";
      add_newline = true;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      battery = {
        full_symbol = "🔋";
        charging_symbol = "⚡️";
        discharging_symbol = "💀";
      };

      cmd_duration = {
        disabled = true;
      };

      git_commit = {
        disabled = true;
      };

      git_branch = {
        disabled = true;
      };

      # Jujutsu統合（starship-jjがNixpkgsにないためコメントアウト）
      # custom.jj = {
      #   command = "prompt";
      #   format = "$output ";
      #   ignore_timeout = true;
      #   shell = ["starship-jj" "--ignore-working-copy" "starship"];
      #   use_stdin = false;
      #   detect_folders = [".jj"];
      #   when = "jj root >/dev/null 2>/dev/null";
      # };
    };
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # mcfly (シェル履歴検索)
  programs.mcfly = {
    enable = true;
    enableFishIntegration = true;
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
  };

  # その他のパッケージ
  home.packages = with pkgs; [
    # starship-jj  # Starshipのjujutsu統合（Nixpkgsに存在しない）
  ];
}
