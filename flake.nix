{
  description = "NixOS + Home-Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprselect-src = {
      url = "github:K-REBO/hyprselect";
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

    weathr.url = "github:Veirt/weathr";

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    crane.url = "github:ipetkov/crane";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tp-render-src = {
      url = "github:K-REBO/tp-render";
      flake = false;
    };

    gh-grass-src = {
      url = "github:koki-develop/gh-grass";
      flake = false;
    };

    obsidian-vault-cli = {
      url = "github:K-REBO/obsidian-vault-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, wayland-fcitx5-indicator, agenix, nur, weathr, nix-index-database, deploy-rs, obsidian-vault-cli, ... }@inputs: let
    system = "x86_64-linux";

    # nixpkgs-unstable より新しいバージョンを使いたい場合はコメントを外してバージョンとhashを更新する
    # yt-dlpOverlay = final: prev: {
    #   yt-dlp = prev.yt-dlp.overrideAttrs (old: rec {
    #     version = "2026.02.04";
    #     src = final.fetchFromGitHub {
    #       owner = "yt-dlp";
    #       repo = "yt-dlp";
    #       tag = version;
    #       hash = "sha256-KXnz/ocHBftenDUkCiFoBRBxi6yWt0fNuRX+vKFWDQw=";
    #     };
    #   });
    # };

    overlays = [
      (import ./overlays/hyprselect.nix inputs)
      (import ./overlays/twitter-cli.nix)
      (import ./overlays/tp-render.nix inputs)
      (import ./overlays/gh-grass.nix inputs)
      (import ./overlays/apple-color-emoji.nix)
      nur.overlays.default
      inputs.fenix.overlays.default
    ];

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      inherit overlays;
    };
  in {
    # NixOS configuration
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./hosts/nixos/configuration.nix
        agenix.nixosModules.default
        nix-index-database.nixosModules.nix-index
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
              nix-index-database.homeModules.nix-index
              { programs.nix-index.enable = true; }
            ];
          };
          nixpkgs.overlays = overlays;
        }
      ];
    };

    # Demo VM configuration (録画生成用 QEMU VM)
    nixosConfigurations.demo-vm = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = system; }
        ./demo-recorder/nix/vm-config.nix
        { nixpkgs.overlays = overlays; }
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
        nix-index-database.homeModules.nix-index
        { programs.nix-index.enable = true; }
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
