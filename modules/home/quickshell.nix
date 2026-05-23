{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    quickshell
    pamtester   # ロック画面PAM認証
  ];

  home.file.".config/quickshell".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/nix/config/quickshell";
}
