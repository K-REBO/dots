{ pkgs, ... }:

let
  myFortunes = pkgs.runCommand "my-fortunes" {
    nativeBuildInputs = [ pkgs.fortune ];
  } ''
    mkdir -p $out/share/fortune
    cp ${../../assets/fortune}/* $out/share/fortune/
    for f in $out/share/fortune/*; do
      strfile "$f"
    done
  '';
in {
  home.packages = [ pkgs.fortune myFortunes ];

  home.sessionVariables = {
    FORTUNEPATH = "${myFortunes}/share/fortune:${pkgs.fortune}/share/fortune";
  };
}
