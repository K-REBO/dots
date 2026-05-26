{ tp-render-src, ... }: final: prev: {
  tp-render = final.stdenv.mkDerivation {
    pname = "tp-render";
    version = "0.1.0";
    src = tp-render-src;
    nativeBuildInputs = [ final.makeWrapper ];
    installPhase = ''
      mkdir -p $out/lib $out/bin
      cp dist/cli.js $out/lib/tp-render.js
      makeWrapper ${final.nodejs}/bin/node $out/bin/tp-render \
        --add-flags "$out/lib/tp-render.js"
    '';
  };
}
