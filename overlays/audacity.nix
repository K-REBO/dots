# Qt 6.12 の qmlcachegen が吐く AOT 検証コードには
# QQmlPrivate::AOTLookupValidation::Type が入っており、muse framework の
# muse::extensions::Type (muse/framework/extensions/extensionstypes.h) と
# unity build でまとめられた途端に名前が衝突してコンパイルが落ちる
# (nixpkgs の qt6 6.11.2 -> 6.12.0 更新で発生)。
# 該当モジュールだけ unity build を切って回避する。
# 上流 PR がマージされたらこのオーバーレイは削除する。
# https://github.com/NixOS/nixpkgs/pull/577022 (NixOS/nixpkgs#572942)
final: prev: {
  audacity = prev.audacity.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace muse/framework/extensions/qml/Muse/Extensions/CMakeLists.txt \
        --replace-fail 'ALIAS muse::extensions_qml' 'NO_UNITY ALIAS muse::extensions_qml'
    '';
  });
}
