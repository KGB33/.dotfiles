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
  };

  outputs = {
    dagger,
    hmm,
    home-manager,
    mac-app-util,
    nasty,
    niri,
    nixpkgs,
    stylix,
    ...
  }: {
    homeConfigurations = {
      "kgb33@geppetto" = let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
        nasty' = nasty.packages.${system}.nasty;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./linux/home.nix
            stylix.homeManagerModules.stylix
            niri.homeModules.niri
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' nasty';};
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
            stylix.homeManagerModules.stylix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' mac-app-util;};
        };
    };
  };
}
