{ config, lib, pkgs, ... }:

{
  # ====================
  # TLP - Power Management for ThinkPad P16s AMD
  # ====================
  services.tlp = {
    enable = true;
    settings = {
      # バッテリー充電閾値 (ThinkPad専用)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # CPU スケーリング (AMD Ryzen)
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # AMD P-State ドライバー用設定
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # CPUブースト
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # AMD GPU 電源管理
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
      RADEON_DPM_PERF_LEVEL_ON_BAT = "low";

      # Platform Profile (ThinkPad)
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      # WiFi 省電力
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      # USB自動サスペンド
      USB_AUTOSUSPEND = 1;

      # NVMe省電力 (APST)
      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # TLPとpower-profiles-daemonは競合するため無効化
  services.power-profiles-daemon.enable = false;

  # ====================
  # AMD P-State Driver (Ryzen 6000+) & スリープ設定
  # ====================
  boot.kernelParams = [
    "amd_pstate=active"       # AMD P-State EPPドライバーを有効化
    "mem_sleep_default=deep"  # S3スリープを優先
    "noresume"                # スワップ上の古いハイバネーションイメージを無視
    "pcie_aspm=off"           # WCN6855 WMIタイムアウト対策
  ];

  # ====================
  # Firmware Updates (fwupd)
  # ====================
  services.fwupd.enable = true;

  # ====================
  # ThinkPad固有のハードウェアサポート
  # ====================

  # 指紋認証 (P16sに搭載されている場合)
  ## services.fprintd.enable = true;

  # ThinkPad ACPI モジュール
  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  # MicMute LED をユーザーが書き込めるようにする
  # udevのKERNEL/DEVPATHマッチングが "::" を含むデバイス名で機能しないため
  # systemdサービスで起動時にパーミッションを設定する
  systemd.services.micmute-led-perms = {
    description = "Set MicMute LED sysfs permissions";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udevd.service" ];
    script = ''
      chmod 0664 /sys/class/leds/platform::micmute/brightness
      chgrp wheel /sys/class/leds/platform::micmute/brightness
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
