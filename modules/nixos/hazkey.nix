{ lib, inputs, enableHazkey, ... }:

{
  # オプション定義は常にimport（enableHazkey=falseなら何もインストール/起動されない）
  imports = [ inputs.nix-hazkey.nixosModules.hazkey ];

  config = lib.mkIf enableHazkey {
    services.hazkey.enable = true;
  };
}
