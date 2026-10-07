{ config, lib, pkgs, ... }:

let
  mt-power-drum-kit = pkgs.callPackage ../../pkgs/mt-power-drum-kit {};

  # Audacity 4 のユーザーデータ置き場（既定は ~/Audacity4）
  audacityDataDir = "${config.home.homeDirectory}/music/Audacity";

  # Audacity 4 は muse framework 製で、ユーザーデータの基準パスを
  #   QStandardPaths::DocumentsLocation + "/" + "Audacity4"
  # とハードコードしている（muse/framework/global/internal/globalconfiguration.cpp
  # の GlobalConfiguration::userDataPath）。xdg.userDirs で documents = $HOME に
  # しているため ~/Audacity4 が掘られる。GUI に変更項目は無く、Qt は
  # XDG_DOCUMENTS_DIR 環境変数を見ず user-dirs.dirs しか読まないので、
  # 起動時に実際に mkpath される設定キーだけを QSettings の INI に書いて逃がす。
  # キーは QSettings の IniFormat が書く綴り（第1階層が [section]、以降は \ 区切り）。
  # SoundFonts は現状の構成では作られないが、将来 MIDI 周りが有効になった時の保険。
  audacityIni = pkgs.writeText "Audacity4.ini" ''
    [application]
    paths\myPlugins=${audacityDataDir}/Plugins
    paths\mySoundfonts=${audacityDataDir}/SoundFonts

    [project]
    paths\myprojects=${audacityDataDir}/Projects
  '';
in {
  home.packages = [ mt-power-drum-kit pkgs.a2jmidid pkgs.audacity ];

  # BitwigのVST3スキャンパス (~/.vst3) にシムリンクを張る
  home.file.".vst3/MT-PowerDrumKit.vst3".source =
    "${mt-power-drum-kit}/lib/vst3/MT-PowerDrumKit.vst3";

  # Audacityが自分で書き換えるファイルなのでsymlinkにはできない。
  # 既に起動済みでINIがある場合にも効かせたいので、キーが無ければ末尾に追記する。
  # QSettingsは同名セクションが重複していてもマージして読むため、既存の
  # [application] / [project] を触らずに済む（追記したキーは再保存後も残る）。
  home.activation.audacityDataDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    _ai="${config.xdg.configHome}/Audacity/Audacity4.ini"
    if ! ${pkgs.gnugrep}/bin/grep -q myprojects "$_ai" 2>/dev/null; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$_ai")"
      if [ -z "$DRY_RUN_CMD" ]; then
        cat ${audacityIni} >> "$_ai"
      fi
    fi
  '';

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
