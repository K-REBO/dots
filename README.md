# dotfiles

NixOS + Home Manager で管理する個人用dotfiles

![demo](demo-recorder/demo.gif)

## Stack

- **OS**: NixOS (unstable)
- **WM**: Hyprland
- **Bar**: eww
- **Terminal**: Alacritty
- **Shell**: Zsh
- **Prompt**: Starship
- **Launcher**: Rofi
- **IME**: Fcitx5
- **Editor**: VSCode / Vim

## Structure

```
.
├── flake.nix              # Flake entry point
├── home.nix               # Home Manager entry point
├── config/                # Raw config files
│   ├── eww/               # eww widgets
│   ├── fcitx5/            # Fcitx5 settings
│   ├── hypr/              # Hyprland config & scripts
│   └── xremap/            # Key remapping
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
│   │   ├── language-tools.nix
│   │   ├── shell.nix
│   │   ├── themes.nix
│   │   ├── vim.nix
│   │   ├── vscode.nix
│   │   ├── xremap.nix
│   │   ├── zsh.nix
│   │   └── ...
│   └── nixos/             # NixOS modules
├── hosts/
│   └── nixos/             # Host-specific config
└── secrets/               # Encrypted secrets (agenix)
```

## Installation

```bash
# Clone
git clone https://github.com/yourusername/dotfiles ~/.config/nix
cd ~/.config/nix

# NixOS rebuild
sudo nixos-rebuild switch --flake .#nixos

# Or standalone Home Manager
home-manager switch --flake .#bido
```

## Dependencies

Flake inputs:
- [nixpkgs](https://github.com/nixos/nixpkgs) (unstable)
- [home-manager](https://github.com/nix-community/home-manager)
- [agenix](https://github.com/ryantm/agenix) - Secret management
- [NUR](https://github.com/nix-community/NUR)
