{ ... }:

{
  # 中央大学系CLI認証情報を chuo.toml として配置
  # 内容: [auth] セクションに id と password を記述した TOML
  #
  # 初回作成:
  #   cd ~/.config/nix/secrets
  #   agenix -e chuo-credentials.age
  # 内容:
  #   [auth]
  #   id = "学籍番号"
  #   password = "パスワード"
  age.secrets.chuo-credentials = {
    file = ../../secrets/chuo-credentials.age;
    path = "/home/bido/.config/chuo-univ/chuo.toml";
    owner = "bido";
    mode = "0600";
  };
}
