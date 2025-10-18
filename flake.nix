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

    vicinae.url = "github:vicinaehq/vicinae";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [
        inputs.home-manager.flakeModules.home-manager
      ];
      systems = ["x86_64-linux" "aarch64-darwin"];
      flake = {
        homeConfigurations = let
          mkArgs = sys:
            {inherit inputs;}
            // {
              dagger' = inputs.dagger.packages."${sys}";
              hmm' = inputs.hmm.packages."${sys}".hmm;
              nasty' = inputs.nasty.packages."${sys}".nasty;
            };
          defaultModules = [
            ./homes
            inputs.stylix.homeModules.stylix
            inputs.niri.homeModules.niri
            inputs.nixcord.homeModules.nixcord
            inputs.vicinae.homeManagerModules.default
          ];
        in {
          "kgb33" = let
            system = "x86_64-linux";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          in
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = defaultModules;
              extraSpecialArgs = mkArgs system;
            };
          "keltonbassingthwaite" = let
            system = "aarch64-darwin";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          in
            inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              modules = defaultModules;
              extraSpecialArgs = mkArgs system;
            };
        };
        nixosConfigurations = {
          geppetto = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./systems/base/configuration.nix
              ./systems/geppetto/configuration.nix
              inputs.nixos-hardware.nixosModules.framework-16-7040-amd
            ];
          };
          helm = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./systems/base/configuration.nix
              ./systems/helm/configuration.nix
            ];
          };
        };
      };
    });
}
