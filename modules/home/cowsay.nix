{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cowsay
  ];

  # カスタムcowファイルを配置
  home.file.".local/share/cows/unta.cow".source = ../../unta.cow;

  # COWPATHを設定してカスタムcowを利用可能に
  home.sessionVariables = {
    COWPATH = "${pkgs.cowsay}/share/cowsay/cows:${config.home.homeDirectory}/.local/share/cows";
  };
}
