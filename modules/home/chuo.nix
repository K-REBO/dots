{ pkgs, ... }:

{
  # 中央大学関連CLIツール
  home.packages = [
    pkgs.cpr   # chuoprint-cli: プリントポータルCLI
    pkgs.chois # chois-cli: 図書館OPAC CLI
  ];
}
