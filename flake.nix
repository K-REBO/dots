{
  description = "NixOS + Home-Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # Home-Manager configuration (standalone)
    homeConfigurations = {
      "bido" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./modules/alacritty.nix
          ./modules/applications.nix
          ./modules/bash.nix
          ./modules/cli-tools.nix
          ./modules/fcitx5.nix
          ./modules/fonts.nix
          ./modules/git.nix
          ./modules/hyprland.nix
          ./modules/hyprpanel.nix
          ./modules/language-tools.nix
          ./modules/pipewire.nix
          ./modules/polybar.nix
          ./modules/rofi.nix
          ./modules/shell.nix
          ./modules/themes.nix
          ./modules/vim.nix
          ./modules/vscode.nix
          ./modules/wofi.nix
          ./modules/xremap.nix
          ./modules/zsh.nix
        ];
      };
    };

    # Development shell
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nil        # Nix LSP
        nixfmt-rfc-style  # Nix formatter
      ];
    };
  };
}
