{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cowsay
  ];

  # assets/cow/ 配下のcowファイルをまとめて配置（追加時にこのファイルの更新は不要）
  home.file.".local/share/cows".source = ../../assets/cow;

  # COWPATHを設定してカスタムcowを利用可能に
  home.sessionVariables = {
    COWPATH = "${pkgs.cowsay}/share/cowsay/cows:${config.home.homeDirectory}/.local/share/cows";
  };
}
