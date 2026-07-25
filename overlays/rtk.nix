# NUR の rtk (Rust Token Killer) は 0.43.0 時点で dead_code の警告が
# `-D warnings` によりエラー化され、`cargo test` の checkPhase が失敗する。
# 上流のクレートに #[allow(dead_code)] 等の修正が入るまで doCheck を無効化する。
# https://github.com/nix-community/NUR
final: prev: {
  rtk = prev.rtk.overrideAttrs (old: {
    doCheck = false;
  });
}
