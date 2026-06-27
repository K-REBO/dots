let
  # User SSH public keys (can decrypt secrets)
  bido = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvI3ILtsXArrQgy59WCJAsrGxS52qm82Sq/0vYYzicS";

  # System SSH host keys (allow system to decrypt at boot)
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH1G0zc/LhcyKAaM0P/0WSHtM8JwSs10Tm1S8Klb5o2O";

  # Key groups
  users = [ bido ];
  systems = [ nixos ];
  all = users ++ systems;
in
{
  # WiFi password
  "wifi-password.age".publicKeys = all;

  # Mozilla account recovery key
  "mozilla-recovery-key.age".publicKeys = users;

  # Discord Bridge CLI 用環境変数 (DISCORD_TOKEN, DISCORD_SERVER_ID)
  "discord-bridge.env.age".publicKeys = all;

  # 中央大学系CLI共有認証情報 (chuo.toml: [auth] id/password)
  "chuo-credentials.age".publicKeys = all;

  # SSH private key example
  # "ssh-key.age".publicKeys = users;

}
