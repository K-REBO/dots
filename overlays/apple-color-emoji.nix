final: prev: {
  apple-color-emoji = final.stdenvNoCC.mkDerivation {
    pname = "apple-color-emoji";
    version = "macos-26-20260219";
    src = final.fetchurl {
      url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260219-2aa12422/AppleColorEmoji-Linux.ttf";
      sha256 = "062k1zf20mnw6lsflbnsg9hxd07wbds697h5f52d41j7y0x08njk";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    '';
  };
}
