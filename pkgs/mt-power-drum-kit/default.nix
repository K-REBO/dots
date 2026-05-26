{ stdenv, fetchurl, unzip, autoPatchelfHook
, libx11, libxcb, libxcb-util, libxcb-cursor, libxcb-wm, libxcb-image
, libxkbcommon, glib, cairo, pango, fontconfig
}:

stdenv.mkDerivation {
  pname = "mt-power-drum-kit";
  version = "2.1.5.0";

  src = fetchurl {
    url = "https://resources.manda-audio.com/DOWNLOADS/products/mtpdk2_free/2.1.5/MTPDK-2.1.5.0-VST3-64bit-Linux-FULL.zip";
    hash = "sha256-kL+1M4s+d28rHuhW4yuCxDa2he3Q2uYVty3aENFCzUQ=";
  };

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
