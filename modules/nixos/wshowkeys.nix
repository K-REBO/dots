{ pkgs, ... }:

{
  # wshowkeys用 setuid wrapper（入力デバイスアクセスに必要）
  security.wrappers.wshowkeys = {
    source = "${pkgs.wshowkeys}/bin/wshowkeys";
    owner = "root";
    group = "root";
    setuid = true;
  };
}
