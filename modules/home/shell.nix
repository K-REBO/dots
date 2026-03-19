{ config, pkgs, ... }:

{
  # Starship (プロンプト)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

      cmd_duration.disabled = true;
      git_commit.disabled = true;
      git_branch.disabled = true;
      gcloud.disabled = true;
      aws.disabled = true;
    };
  };

  # Zoxide (ディレクトリジャンプ)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # mcfly (シェル履歴検索)
  programs.mcfly = {
    enable = true;
    enableZshIntegration = true;
  };

  # GitHub CLI
  programs.gh.enable = true;
}
