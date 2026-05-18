{ config, pkgs, lib, ... }:

# ===========================================================
# Dwarf Fortress + DFHack + dfint 日本語パッチ
#
# 起動方法:
#   dfhack          → DFHack付き英語版（~/df_linux/）
#   dwarf-fortress  → バニラ英語版
#   df-japanese     → dfint日本語版（~/df_linux_ja/ を使用）
#
# 注意: dfhackとdfintは両方ともlibdfhooks.soを必要とするため
#       同一ホームディレクトリでは共存不可。
#       df-japaneseは専用ディレクトリ df_linux_ja/ で動作する。
# ===========================================================

let
  # NixOS の autoPatchelfHook でパッチ済みのゲームバイナリ
  dfGame = pkgs.dwarf-fortress-packages.dwarf-fortress-original;

  # dfint フックライブラリ（prebuilt .so）
  dfintHook = pkgs.fetchurl {
    url = "https://github.com/dfint/df-steam-hook-rs/releases/download/0.2.1/hook_0.2.1.so";
    hash = "sha256-3K/xq0E8gcsESC+AAOlR/Oi1koXI7/AhezexhnHEppQ=";
  };

  # 日本語辞書（autobuild リポジトリの固定コミットから）
  dfintDictionary = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/dfint/autobuild/4ef64c9008ddd8d1bc877a6ab63205e3cdb2e822/translation_build/csv/Japanese/dfint_dictionary.csv";
    hash = "sha256-r5fiC/qqMhimnotf1WRqEK3wOLRV/jRJpdsTZewp3tE=";
  };

  # dfintオフセットファイル（NixOSパッチ済みバイナリのCRC32を動的計算）
  # dfintはCRC32でゲームバイナリを識別するため、autoPatchelfHook後の
  # 実際のバイナリのハッシュでoffsets.tomlを生成する必要がある
  dfintOffsets = pkgs.runCommand "dfint-offsets-53.11-nixos" {
    nativeBuildInputs = [ pkgs.python3 ];
    inherit dfGame;
  } ''
    checksum=$(python3 <<'PYEOF'
import binascii
with open('${dfGame}/dwarfort', 'rb') as f:
    data = f.read()
crc = binascii.crc32(data) & 0xffffffff
print(hex(crc))
PYEOF
)
    cat > $out << TOMLEOF
[metadata]
name = "dfint localization hook offsets"
version = "53.11 other linux64 (nixos)"
checksum = $checksum

[offsets]
utf_input = 0x38d

[symbols]
enabler = ["self", "enabler"]
std_string_append = ["self", "_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6appendEPKc"]
std_string_assign = ["self", "_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE6assignEPKc"]
addst = ["libg_src_lib.so", "_ZN9graphicst5addstERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE13justificationi"]
addst_top = ["libg_src_lib.so", "_ZN9graphicst9top_addstERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE13justificationi"]
addst_flag = ["libg_src_lib.so", "_ZN9graphicst10addst_flagERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE13justificationij"]
standardstringentry = ["libg_src_lib.so", "_Z19standardstringentryRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEijRSt3setIlSt4lessIlESaIlEEPKc"]
simplify_string = ["libg_src_lib.so", "_Z15simplify_stringRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"]
upper_case_string = ["libg_src_lib.so", "_Z17upper_case_stringRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"]
lower_case_string = ["libg_src_lib.so", "_Z17lower_case_stringRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"]
capitalize_string_words = ["libg_src_lib.so", "_Z23capitalize_string_wordsRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"]
capitalize_string_first_word = ["libg_src_lib.so", "_Z28capitalize_string_first_wordRNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE"]
TOMLEOF
  '';

  # dfint 日本語パッチ一式（フック + 設定ファイル + 辞書）
  dfintJapanese = pkgs.runCommand "dfint-japanese-53.11" { } ''
    mkdir -p $out/dfint-data

    cp ${dfintHook}      $out/libdfhooks.so
    cp ${dfintOffsets}   $out/dfint-data/offsets.toml
    cp ${dfintDictionary} $out/dfint-data/dictionary.csv

    cat > $out/dfint-data/config.toml << 'EOF'
[metadata]
name = "dfint localization hook"

[settings]
log_level = 4
log_file = "/tmp/dfint-log.log"
enable_search = true
enable_translation = true
watchdog = true
EOF

    cat > $out/dfint-data/encoding.toml << 'EOF'
[metadata]
encoding = "cp437"
EOF
  '';

  # DFHack付きDwarf Fortress（Linux ではデフォルトで有効）
  dfFull = pkgs.dwarf-fortress-packages.dwarf-fortress-full;

  # 日本語モード起動スクリプト
  # nixpkgsラッパーが cleanup_path でシンボリックリンクのみ削除するため、
  # dfintファイルを「実ファイル」としてコピーすることで削除を回避する
  dfJapanese = pkgs.writeShellScriptBin "df-japanese" ''
    set -e
    JA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}/df_linux_ja"
    mkdir -p "$JA_HOME/dfint-data"

    # dfintファイルを実ファイルとしてコピー（シンボリックリンク不可）
    cp -f ${dfintJapanese}/libdfhooks.so             "$JA_HOME/libdfhooks.so"
    cp -f ${dfintJapanese}/dfint-data/offsets.toml   "$JA_HOME/dfint-data/offsets.toml"
    cp -f ${dfintJapanese}/dfint-data/config.toml    "$JA_HOME/dfint-data/config.toml"
    cp -f ${dfintJapanese}/dfint-data/encoding.toml  "$JA_HOME/dfint-data/encoding.toml"
    cp -f ${dfintJapanese}/dfint-data/dictionary.csv "$JA_HOME/dfint-data/dictionary.csv"

    export NIXPKGS_DF_HOME="$JA_HOME"
    exec ${dfFull}/bin/dwarf-fortress "$@"
  '';

in {
  home.packages = [
    dfFull       # dfhack / dwarf-fortress コマンドを提供
    dfJapanese   # df-japanese コマンドを提供
  ];
}
