{ config, pkgs, ... }:

{
  # フォント設定
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Noto フォントファミリーは configuration.nix (fonts.packages) で管理

    # noto-fonts-cjk-serif は configuration.nix に含まれていないため Home Manager で追加
    noto-fonts-cjk-serif         # 日本語・中国語・韓国語（Serif）

    # DejaVu フォント
    dejavu_fonts                 # プログラミング・汎用

    # Liberation フォント（MS Office互換）
    liberation_ttf               # Arial, Times New Roman, Courier New代替

    # Nerd Fonts（アイコン統合プログラミングフォント）
    nerd-fonts.ubuntu-mono       # 既存設定で使用
    nerd-fonts.jetbrains-mono    # polybarで使用
    nerd-fonts.fira-code         # オプション
    nerd-fonts.hack              # オプション

    # GNOME用（afdko 5.0.1との非互換でビルド失敗するためコメントアウト）
    # cantarell-fonts

    # プログラミング用
    source-code-pro              # VSCodeで使用
    # jetbrains-mono               # polybarで使用 (nerd-fonts.jetbrains-monoで代替)

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
          <family>Apple Color Emoji</family>
        </prefer>
      </alias>

      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans CJK JP</family>
          <family>Noto Sans</family>
          <family>Apple Color Emoji</family>
        </prefer>
      </alias>

      <alias>
        <family>monospace</family>
        <prefer>
          <family>UbuntuMono Nerd Font</family>
          <family>JetBrains Mono</family>
          <family>Source Code Pro</family>
          <family>Apple Color Emoji</family>
        </prefer>
      </alias>

      <!-- 絵文字フォント優先順位 -->
      <alias>
        <family>emoji</family>
        <prefer>
          <family>Apple Color Emoji</family>
          <family>Noto Color Emoji</family>
        </prefer>
      </alias>

      <!-- Noto Color Emoji をApple Color Emojiに置き換え -->
      <match target="pattern">
        <test qual="any" name="family"><string>Noto Color Emoji</string></test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Apple Color Emoji</string>
        </edit>
      </match>

      <!-- Nerd Font (UbuntuMono Nerd Font等) にないCJK文字をフォールバックする際、
           fontconfigの自動探索ではNoto *CJK KR/SC/TC/HKがJPより先に選ばれてしまう
           (Han unificationにより「習」等の字形が中国語/韓国語風になる)。
           クエリのfamilyリストに明示的にJP版を追加し、確実にJPが選ばれるようにする -->
      <match target="pattern">
        <test name="family" compare="contains"><string>Nerd Font</string></test>
        <edit name="family" mode="append" binding="weak">
          <string>Noto Sans Mono CJK JP</string>
        </edit>
        <edit name="family" mode="append" binding="weak">
          <string>Noto Sans CJK JP</string>
        </edit>
      </match>

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
