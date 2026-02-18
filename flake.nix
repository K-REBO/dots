{
  description = "NixOS + Home-Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wmfocus-src = {
      url = "github:K-REBO/wmfocus";
      flake = false;
    };

    wayland-fcitx5-indicator = {
      url = "github:K-REBO/wayland_fcitx5_indicator";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, home-manager, wmfocus-src, wayland-fcitx5-indicator, agenix, nur, ... }@inputs: let
    system = "x86_64-linux";

    yt-dlpOverlay = final: prev: {
      yt-dlp = prev.yt-dlp.overrideAttrs (old: rec {
        version = "2026.02.04";
        src = final.fetchFromGitHub {
          owner = "yt-dlp";
          repo = "yt-dlp";
          tag = version;
          hash = "sha256-KXnz/ocHBftenDUkCiFoBRBxi6yWt0fNuRX+vKFWDQw=";
        };
      });
    };

    wmfocusOverlay = final: prev: {
      wmfocus = final.rustPlatform.buildRustPackage {
        pname = "wmfocus";
        version = "1.5.0";
        src = wmfocus-src;
        cargoLock.lockFile = "${wmfocus-src}/Cargo.lock";
        buildFeatures = [ "hyprland" ];
        nativeBuildInputs = with final; [ pkg-config cmake ];
        buildInputs = with final; [
          cairo
          libxcb
          libx11
          fontconfig
          wayland
          libxkbcommon
          expat
          freetype
        ];
        # テストを無効化（テストコードにコンパイルエラーあり）
        doCheck = false;
        # expat-sys cmake互換性問題の回避
        preBuild = ''
          export CMAKE_POLICY_VERSION_MINIMUM=3.5
        '';
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ yt-dlpOverlay wmfocusOverlay nur.overlays.default ];
    };
  in {
    # NixOS configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos/configuration.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.bido = { ... }: {
            imports = [
              ./home.nix
              wayland-fcitx5-indicator.homeManagerModules.default
              { programs.wayland-fcitx5-indicator.enable = true; }
            ];
          };
          nixpkgs.overlays = [ yt-dlpOverlay wmfocusOverlay nur.overlays.default ];
        }
      ];
    };

    # Home-Manager configuration (standalone - for testing without rebuild)
    homeConfigurations."bido" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home.nix
        wayland-fcitx5-indicator.homeManagerModules.default
        { programs.wayland-fcitx5-indicator.enable = true; }
      ];
    };

    # Development shell
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nil        # Nix LSP
        nixfmt-rfc-style  # Nix formatter
        agenix.packages.${system}.default  # Secret management CLI
      ];
    };
  };
}
