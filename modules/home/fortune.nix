{ pkgs, ... }:

let
  myFortunes = pkgs.runCommand "my-fortunes" {
    nativeBuildInputs = [ pkgs.fortune ];
  } ''
    mkdir -p $out/share/fortune
    cp ${../../assets/fortune/custom} $out/share/fortune/custom
    strfile $out/share/fortune/custom
  '';
in {
  home.packages = [ pkgs.fortune myFortunes ];

  home.sessionVariables = {
    FORTUNEPATH = "${myFortunes}/share/fortune:${pkgs.fortune}/share/fortune";
  };
}
