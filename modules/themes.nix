{ config, pkgs, ... }:

{
  # GTK/Qt テーマ設定

  # GTKテーマ
  gtk = {
    enable = true;

    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  # Qtテーマ（GTKテーマを使用）
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # テーマパッケージ
  home.packages = with pkgs; [
    # アイコンテーマ
    papirus-icon-theme
    # eos-qogir-icons  # EndeavourOS特有（Nixにない可能性）

    # GTKテーマ
    dracula-theme
    # arc-theme  # Arc-Darkテーマ
    adwaita-icon-theme

    # カーソルテーマ
    gnome.adwaita-icon-theme

    # Qt統合
    libsForQt5.qtstyleplugins
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
  ];

  # ダークモード設定
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Dracula";
    };
  };

  # 環境変数
  home.sessionVariables = {
    # Qt
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };
}
