{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;

    # nix-shell用の最小限PATH（スクリプト実行専用のため対話設定は持たない）
    bashrcExtra = ''
      export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.deno/bin:$HOME/.moon/bin:$HOME/.go/bin:$PATH"
    '';
  };
}
