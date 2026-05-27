{ pkgs, ... }:

let
  mt-power-drum-kit = pkgs.callPackage ../../pkgs/mt-power-drum-kit {};
in {
  home.packages = [ mt-power-drum-kit pkgs.a2jmidid ];

  # BitwigのVST3スキャンパス (~/.vst3) にシムリンクを張る
  home.file.".vst3/MT-PowerDrumKit.vst3".source =
    "${mt-power-drum-kit}/lib/vst3/MT-PowerDrumKit.vst3";

  # ALSA MIDIデバイスをPipeWireにブリッジ（nanoPAD等をBitwigで認識させる）
  systemd.user.services.a2jmidid = {
    Unit = {
      Description = "ALSA to JACK MIDI bridge";
      After = [ "pipewire.service" ];
    };
    Service = {
      ExecStart = "${pkgs.a2jmidid}/bin/a2jmidid -e";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
