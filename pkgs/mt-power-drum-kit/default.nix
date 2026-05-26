{ stdenv, unzip, autoPatchelfHook
, libx11, libxcb, libxcb-util, libxcb-cursor, libxcb-wm, libxcb-image
, libxkbcommon, glib, cairo, pango, fontconfig
}:

stdenv.mkDerivation {
  pname = "mt-power-drum-kit";
  version = "2.1.5.0";

  src = ../../private/MTPDK-2.1.5.0-VST3-64bit-Linux-FULL.zip;

  nativeBuildInputs = [ unzip autoPatchelfHook ];

  buildInputs = [
    libx11 libxcb libxcb-util libxcb-cursor libxcb-wm libxcb-image
    libxkbcommon glib cairo pango fontconfig
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    unzip $src "MT-PowerDrumKit.vst3/*"
  '';

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/vst3
    cp -r MT-PowerDrumKit.vst3 $out/lib/vst3/
  '';

  meta.platforms = [ "x86_64-linux" ];
}
