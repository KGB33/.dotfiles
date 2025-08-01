{
  description = "Home Manager configuration of kgb33";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dagger = {
      url = "github:dagger/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hmm.url = "github:KGB33/hmm";

    nasty.url = "github:KGB33/nasty";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";

    stylix.url = "github:danth/stylix";

    nixcord.url = "github:kaylorben/nixcord";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # TODO: Use nixpkgs version once its updated to 0.12.x
    television.url = "github:alexpasmantier/television";
  };

  outputs = {
    dagger,
    hmm,
    home-manager,
    mac-app-util,
    nasty,
    niri,
    nixcord,
    nixos-hardware,
    nixpkgs,
    stylix,
    television,
    ...
  }: {
    homeConfigurations = {
      "kgb33@geppetto" = let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
        nasty' = nasty.packages.${system}.nasty;
        tv = television.packages.${system}.default;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./linux/home.nix
            stylix.homeModules.stylix
            niri.homeModules.niri
            nixcord.homeModules.nixcord
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' nasty' tv;};
        };
      "keltonbassingthwaite" = let
        system = "aarch64-darwin";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./darwin/home.nix
            stylix.homeModules.stylix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' mac-app-util;};
        };
    };
    nixosConfigurations = {
      geppetto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/base/configuration.nix
          ./systems/geppetto/configuration.nix
          nixos-hardware.nixosModules.framework-16-7040-amd
        ];
      };
    };
  };
}
