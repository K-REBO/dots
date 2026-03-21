# dotfiles

NixOS + Home Manager で管理する個人用dotfiles

![demo](demo-recorder/demo.gif)

## Stack

- **OS**: NixOS (unstable)
- **WM**: Hyprland
- **Bar**: eww
- **Terminal**: Alacritty
- **Shell**: Zsh + Starship
- **Launcher**: vicinae
- **IME**: Fcitx5
- **Editor**: VSCode / Vim

## Structure

```
.
├── flake.nix              # Flake entry point
├── home.nix               # Home Manager entry point
├── config/                # Raw config files
│   ├── eww/               # eww widgets & scripts
│   ├── fcitx5/            # Fcitx5 settings
│   ├── hypr/              # Hyprland config, wallpapers & scripts
│   ├── vicinae/           # vicinae launcher config
│   ├── xremap/            # Key remapping
│   └── quickshell/        # quickshell widgets
├── modules/
│   ├── home/              # Home Manager modules
│   │   ├── alacritty.nix
│   │   ├── applications.nix
│   │   ├── cli-tools.nix
│   │   ├── eww.nix
│   │   ├── fcitx5.nix
│   │   ├── fonts.nix
│   │   ├── git.nix
│   │   ├── hyprland.nix
│   │   ├── niri.nix
│   │   ├── language-tools.nix
│   │   ├── shell.nix
│   │   ├── themes.nix
│   │   ├── vim.nix
│   │   ├── vscode.nix
│   │   ├── vicinae.nix
│   │   ├── zsh.nix
│   │   └── ...
│   └── nixos/             # NixOS modules
├── hosts/
│   └── nixos/             # Host-specific config
├── demo-recorder/         # 再現性のあるデモGIF生成ツール
│   ├── demos/             # デモスクリプト (JSON)
│   ├── nix/               # VM設定
│   ├── scripts/           # replay-engine, make-gif, run-demo
│   └── wm/hyprland/       # WM別設定
└── secrets/               # Encrypted secrets (agenix)
```

## Demo Recorder

QEMU VM 上で headless Hyprland を起動し、`demos/demo.json` に記述したアクションを自動実行して GIF を生成するサブツール。

```bash
# VM ビルド (初回のみ)
nix build .#nixosConfigurations.demo-vm.config.system.build.vm

# GIF 生成
./demo-recorder/scripts/run-demo
```

詳細は [demo-recorder/README.md](demo-recorder/README.md) を参照。

## Installation

```bash
# Clone
git clone https://github.com/K-REBO/dotfiles ~/.config/nix
cd ~/.config/nix

# NixOS rebuild
sudo nixos-rebuild switch --flake .#nixos

# Or standalone Home Manager
home-manager switch --flake .#bido
```

## Flake Inputs

- [nixpkgs](https://github.com/nixos/nixpkgs) (unstable)
- [home-manager](https://github.com/nix-community/home-manager)
- [agenix](https://github.com/ryantm/agenix) - Secret management
- [NUR](https://github.com/nix-community/NUR)
- [crane](https://github.com/ipetkov/crane) + [fenix](https://github.com/nix-community/fenix) - Rust builds
- [deploy-rs](https://github.com/serokell/deploy-rs) - Deployment
