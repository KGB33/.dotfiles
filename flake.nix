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
    ghostty.url = "github:ghostty-org/ghostty";
    hmm.url = "github:KGB33/hmm";
    nasty.url = "github:KGB33/nasty";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    nixpkgs,
    home-manager,
    ghostty,
    dagger,
    hmm,
    nasty,
    mac-app-util,
    ...
  }: {
    homeConfigurations = {
      "kgb33@geppetto" = let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
        nasty' = nasty.packages.${system}.nasty;
        ghostty' = ghostty.packages.${system}.default;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./linux/home.nix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' nasty' ghostty';};
        };
      "keltonbassingthwaite@kelton-mbp.cdl.local" = let
        system = "aarch64-darwin";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
        ghostty' = ghostty.packages.${system}.default;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./darwin/home.nix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' ghostty' mac-app-util;};
        };
    };
  };
}
