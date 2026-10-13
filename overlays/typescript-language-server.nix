# nixpkgs の typescript-language-server 6.0.2 は pnpmDeps の
# outputHash が実際のフェッチ結果と一致せず、hash mismatch でビルドが落ちる。
# 上流で hash が修正されるまでローカルで実測値に差し替える。
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/ty/typescript-language-server/package.nix
final: prev: {
  typescript-language-server = prev.typescript-language-server.overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
      outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
    });
  });
}
