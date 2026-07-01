{ lib, python3, makeWrapper, runCommandLocal }:

let
  pythonEnv = python3.withPackages (ps: [ ps.playwright ]);
in
runCommandLocal "google-map-bookmark"
{
  nativeBuildInputs = [ makeWrapper ];
  meta = with lib; {
    description = "店名やURLからGoogle Mapsのリストに保存するCLI (Playwrightによるブラウザ自動操作)";
    platforms = platforms.linux;
  };
}
''
  mkdir -p $out/libexec $out/bin
  install -m755 ${./google_map_bookmark.py} $out/libexec/google_map_bookmark.py
  makeWrapper ${pythonEnv}/bin/python3 $out/bin/google-map-bookmark \
    --add-flags $out/libexec/google_map_bookmark.py
''
