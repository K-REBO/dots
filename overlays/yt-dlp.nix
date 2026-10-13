# yt-dlp は対象サイトの仕様変更で頻繁に壊れ、修正はまず master に入ってから
# リリースされる。nixpkgs のリリース版ではなく flake input の master HEAD を使う。
#
# 最新に上げる: nix flake update yt-dlp-src
# リリース版に戻す: flake.nix のオーバーレイ一覧からこの行を外す
{ yt-dlp-src, ... }:
final: prev: let
  # lastModifiedDate は "20261010211552" 形式。
  # yt-dlp 公式の master ビルドと同じ "2026.10.10.211552" 形式に組み替える。
  d = yt-dlp-src.lastModifiedDate;
  part = start: len: builtins.substring start len d;
  version = "${part 0 4}.${part 4 2}.${part 6 2}.${part 8 6}";
in {
  yt-dlp = prev.yt-dlp.overrideAttrs (old: {
    inherit version;
    src = yt-dlp-src;

    # master の yt_dlp/version.py は直前のリリース時点のまま自動生成されているので、
    # `yt-dlp --version` が嘘をつく。実際に使っている commit を反映させる。
    # (-v のバナーが "stable@" と出るのは ORIGIN から引かれるラベルで、
    #  実体は併記される RELEASE_GIT_HEAD の方)
    postPatch = old.postPatch + ''
      sed -i \
        -e "s|^__version__ = .*|__version__ = '${version}'|" \
        -e "s|^_pkg_version = .*|_pkg_version = '${version}'|" \
        -e "s|^RELEASE_GIT_HEAD = .*|RELEASE_GIT_HEAD = '${yt-dlp-src.rev}'|" \
        yt_dlp/version.py
    '';

    meta = old.meta // {
      changelog = "https://github.com/yt-dlp/yt-dlp/blob/${yt-dlp-src.rev}/Changelog.md";
    };
  });
}
