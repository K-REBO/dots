{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    # ユーザー情報
    userName = "Bido Nakamura";
    userEmail = "K-REBO@users.noreply.github.com";

    # デフォルトエディタ
    extraConfig = {
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
        helper = "/usr/libexec/git-core/git-credential-libsecret";
      };
    };

    # エイリアス
    aliases = {
      staged = "diff --cached --name-only";
    };

    # deltaは既にcli-tools.nixでインストール済み
  };
}
