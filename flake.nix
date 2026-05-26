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

    dots-private = {
      url = "git+ssh://git@github.com/K-REBO/dots-private";
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

  outputs = { self, nixpkgs, home-manager, hyprselect-src, wayland-fcitx5-indicator, agenix, nur, weathr, nix-index-database, deploy-rs, crane, fenix, tp-render-src, gh-grass-src, ... }@inputs: let
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

    hyprselectOverlay = final: prev: {
      hyprselect = let
        craneLib = (crane.mkLib final).overrideToolchain final.fenix.stable.toolchain;
        commonArgs = {
          src = hyprselect-src;
          strictDeps = true;
          cargoExtraArgs = "--features hyprland";
          nativeBuildInputs = with final; [ pkg-config cmake autoPatchelfHook ];
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
        # 依存クレートを先にビルド → Nixストアにキャッシュ
        cargoArtifacts = craneLib.buildDepsOnly commonArgs;
      in craneLib.buildPackage (commonArgs // {
        inherit cargoArtifacts;
        pname = "hyprselect";
        version = "1.5.0";
      });
    };

    twitterCliOverlay = final: prev: let
      pyPkgs = prev.python3.pkgs;
      xclienttransaction = pyPkgs.buildPythonPackage rec {
        pname = "xclienttransaction";
        version = "1.0.2";
        format = "wheel";
        src = final.fetchurl {
          url = "https://files.pythonhosted.org/packages/py3/x/xclienttransaction/xclienttransaction-${version}-py3-none-any.whl";
          sha256 = "sha256-ZiUVVPAkcs0Ps6M7xkaM/rdAlJdU3cB9vkFk5DmshhM=";
        };
        dependencies = with pyPkgs; [ beautifulsoup4 ];
        pythonRuntimeDepsCheckHook = false;
        doCheck = false;
      };
    in {
      twitter-cli = pyPkgs.buildPythonApplication rec {
        pname = "twitter-cli";
        version = "0.8.5";
        format = "wheel";
        src = final.fetchurl {
          url = "https://files.pythonhosted.org/packages/py3/t/twitter_cli/twitter_cli-${version}-py3-none-any.whl";
          sha256 = "sha256-sudyBOrnFZ4Q4Znjv1KWppFGlFeSnN+QoHDMUXLzkxc=";
        };
        dependencies = with pyPkgs; [
          beautifulsoup4
          browser-cookie3
          click
          curl-cffi
          pyyaml
          rich
          xclienttransaction
        ];
        doCheck = false;
      };
    };

    ghGrassOverlay = final: prev: {
      gh-grass = final.buildGoModule {
        pname = "gh-grass";
        version = "unstable-2025";
        src = gh-grass-src;
        vendorHash = "sha256-lvSdQ09zg8PfVSkKoZ49VwXRVmxI1J8IAONAHBXwmEg=";
      };
    };

    appleColorEmojiOverlay = final: prev: {
      apple-color-emoji = final.stdenvNoCC.mkDerivation {
        pname = "apple-color-emoji";
        version = "macos-26-20260219";
        src = final.fetchurl {
          url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260219-2aa12422/AppleColorEmoji-Linux.ttf";
          sha256 = "062k1zf20mnw6lsflbnsg9hxd07wbds697h5f52d41j7y0x08njk";
        };
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp $src $out/share/fonts/truetype/AppleColorEmoji.ttf
        '';
      };
    };

    tpRenderOverlay = final: prev: {
      tp-render = final.stdenv.mkDerivation {
        pname = "tp-render";
        version = "0.1.0";
        src = tp-render-src;
        nativeBuildInputs = [ final.makeWrapper ];
        installPhase = ''
          mkdir -p $out/lib $out/bin
          cp dist/cli.js $out/lib/tp-render.js
          makeWrapper ${final.nodejs}/bin/node $out/bin/tp-render \
            --add-flags "$out/lib/tp-render.js"
        '';
      };
    };

    overlays = [ hyprselectOverlay twitterCliOverlay tpRenderOverlay ghGrassOverlay appleColorEmojiOverlay nur.overlays.default fenix.overlays.default ];  # claudeOverlay無効化

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
