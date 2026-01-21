{ config, pkgs, ... }:

{
  # フォント設定
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Noto フォントファミリー（Google）
    noto-fonts                    # 基本
    noto-fonts-cjk-sans          # 日本語・中国語・韓国語（Sans）
    noto-fonts-cjk-serif         # 日本語・中国語・韓国語（Serif）
    noto-fonts-emoji             # 絵文字
    noto-fonts-extra             # 追加言語

    # DejaVu フォント
    dejavu_fonts                 # プログラミング・汎用

    # Liberation フォント（MS Office互換）
    liberation_ttf               # Arial, Times New Roman, Courier New代替

    # Nerd Fonts（アイコン統合プログラミングフォント）
    (nerdfonts.override {
      fonts = [
        "UbuntuMono"             # 既存設定で使用
        "JetBrainsMono"          # polybarで使用
        "FiraCode"               # オプション
        "Hack"                   # オプション
      ];
    })

    # GNOME用
    cantarell-fonts

    # プログラミング用
    source-code-pro              # VSCodeで使用
    jetbrains-mono               # polybarで使用

    # 日本語フォント（追加）
    # IPAフォント（日本語）
    ipafont
    # IPA P明朝（Emacsで使用していたが、使わない場合はコメントアウト）
    # ipaexfont

    # その他
    font-awesome                 # アイコンフォント（wofiで使用）
  ];

  # フォント設定（オプション）
  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- デフォルトフォント設定 -->
      <alias>
        <family>serif</family>
        <prefer>
          <family>Noto Serif CJK JP</family>
          <family>Noto Serif</family>
        </prefer>
      </alias>

      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans CJK JP</family>
          <family>Noto Sans</family>
        </prefer>
      </alias>

      <alias>
        <family>monospace</family>
        <prefer>
          <family>UbuntuMono Nerd Font</family>
          <family>JetBrains Mono</family>
          <family>Source Code Pro</family>
        </prefer>
      </alias>

      <!-- 日本語フォント優先順位 -->
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans CJK JP</family>
        </prefer>
      </alias>
    </fontconfig>
  '';
}
