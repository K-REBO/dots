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

  # SSH private key example
  # "ssh-key.age".publicKeys = users;

  # API tokens, database passwords, etc.
  # "api-token.age".publicKeys = users;
}
