{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
    };
    settings.commit.gpgsign = true;

    # 新形式: settings
    settings = {
      # ユーザー情報
      user = {
        name = "Bido Nakamura";
        email = "K-REBO@users.noreply.github.com";
      };

      # エイリアス
      alias = {
        staged = "diff --cached --name-only";
      };

      core = {
        editor = "vim";
        pager = "delta";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = true;
        plus-style = "syntax #012800";
        minus-style = "syntax #340001";
        syntax-theme = "Monokai Extended";
      };

      merge = {
        conflictstyle = "diff3";
      };

      diff = {
        colorMoved = "default";
      };

      credential = {
        helper = "${pkgs.gitFull}/libexec/git-core/git-credential-libsecret";
      };
    };

    # deltaは既にcli-tools.nixでインストール済み
  };
}
