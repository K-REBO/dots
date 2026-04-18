{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # nix-shell用の最小限PATH（スクリプト実行専用のため対話設定は持たない）
    bashrcExtra = ''
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/.deno/bin:$PATH"
      export PATH="$HOME/.moon/bin:$PATH"
      export PATH="$HOME/.go/bin:$PATH"
    '';
  };
}
