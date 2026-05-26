{ hyprselect-src, crane, ... }: final: prev: {
  hyprselect = let
    craneLib = (crane.mkLib final).overrideToolchain final.fenix.stable.toolchain;
    commonArgs = {
      src = hyprselect-src;
      strictDeps = true;
      cargoExtraArgs = "--features hyprland";
      nativeBuildInputs = with final; [ pkg-config cmake autoPatchelfHook ];
      buildInputs = with final; [
        cairo
        libxcb
        libx11
        fontconfig
        wayland
        libxkbcommon
        expat
        freetype
      ];
      # テストを無効化（テストコードにコンパイルエラーあり）
      doCheck = false;
      # expat-sys cmake互換性問題の回避
      preBuild = ''
        export CMAKE_POLICY_VERSION_MINIMUM=3.5
      '';
    };
    # 依存クレートを先にビルド → Nixストアにキャッシュ
    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
  in craneLib.buildPackage (commonArgs // {
    inherit cargoArtifacts;
    pname = "hyprselect";
    version = "1.5.0";
  });
}
