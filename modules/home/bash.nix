{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # 最小限のPATH設定（nix-shell用）
    bashrcExtra = ''
      # PATH設定
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.deno/bin:$PATH"
      export PATH="$HOME/.moon/bin:$PATH"
      export GO_HOME="$HOME/.go"
      export PATH="$GO_HOME/bin:$PATH"

      # LD_LIBRARY_PATH
      export LD_LIBRARY_PATH="/usr/lib:$LD_LIBRARY_PATH"
    '';

    shellAliases = {
      ls = "ls --color=auto";
    };

    historySize = 10000;
    historyFileSize = 20000;
    historyControl = [ "ignoredups" "ignorespace" ];
  };
}
