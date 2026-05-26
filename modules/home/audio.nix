{ pkgs, inputs, ... }:

let
  mt-power-drum-kit = pkgs.callPackage ../../pkgs/mt-power-drum-kit {
    src = "${inputs.dots-private}/MTPDK-2.1.5.0-VST3-64bit-Linux-FULL.zip";
  };
in {
  home.packages = [ mt-power-drum-kit ];

  # BitwigのVST3スキャンパス (~/.vst3) にシムリンクを張る
  home.file.".vst3/MT-PowerDrumKit.vst3".source =
    "${mt-power-drum-kit}/lib/vst3/MT-PowerDrumKit.vst3";
}
