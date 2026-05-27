{ config, pkgs, ... }:

let
  gnome-macos-tahoe = pkgs.stdenv.mkDerivation {
    pname = "gnome-macos-tahoe";
    version = "2024-01-26";
    src = pkgs.fetchFromGitHub {
      owner = "kayozxo";
      repo = "GNOME-macOS-Tahoe";
      rev = "195443b38d80f1ec4971ebae9a7277df6d12bc10";
      hash = "sha256-A0YOqjvWC41TCg2SymLEyXrNX2ArElyezJzh0Q1Hsd0=";
    };
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/themes
      cp -r gtk/Tahoe-Dark $out/share/themes/
      cp -r gtk/Tahoe-Light $out/share/themes/
      # libadwaita用にGTK4 CSSも出力
      mkdir -p $out/share/gtk-4.0
      cp gtk/Tahoe-Dark/gtk-4.0/gtk.css $out/share/gtk-4.0/
      runHook postInstall
    '';
  };
  colloid-with-fallbacks = pkgs.colloid-icon-theme.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      for f in $out/share/icons/Colloid*/index.theme; do
        sed -i 's/Inherits=hicolor,breeze/Inherits=Tela-dark,Papirus-Dark,hicolor,breeze/' "$f"
      done
    '';
  });
in
{
  # GTK/Qt テーマ設定

  # GTKテーマ
  gtk = {
    enable = true;

    theme = {
      name = "Tahoe-Dark";
      package = gnome-macos-tahoe;
    };

    iconTheme = {
      name = "Colloid-dark";
      package = colloid-with-fallbacks;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # GTK4/libadwaita: TahoeテーマのCSSをインポート（テーマ名はlibadwaitaでは無効なのでnull）
    gtk4.theme = null;
    gtk4.extraCss = builtins.readFile "${gnome-macos-tahoe}/share/gtk-4.0/gtk.css";
  };

  # Qtテーマ（GTKテーマを使用）
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # テーマパッケージ
  home.packages = [
    # GTKテーマ
    gnome-macos-tahoe

    # アイコンテーマ（Colloid → Tela → Papirus フォールバックチェーン）
    colloid-with-fallbacks
    pkgs.tela-icon-theme
    pkgs.papirus-icon-theme
    pkgs.adwaita-icon-theme

    # カーソルテーマ
    pkgs.bibata-cursors

    # Qt統合
    pkgs.libsForQt5.qtstyleplugins
    pkgs.qt6.qtwayland
    pkgs.libsForQt5.qt5.qtwayland
  ];

  # ダークモード設定
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Tahoe-Dark";
    };
  };

  # 環境変数
  home.sessionVariables = {
    # Qt
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

}
