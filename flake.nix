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
    wezterm-flake = {
      # Unstable pkg is broken - https://github.com/NixOS/nixpkgs/issues/336069
      url = "github:wez/wezterm/main?dir=nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    nixpkgs,
    home-manager,
    ghostty,
    dagger,
    hmm,
    nasty,
    wezterm-flake,
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
        wezterm' = wezterm-flake.packages.${system}.default;
        ghostty' = ghostty.packages.${system}.default;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./linux/home.nix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' nasty' wezterm' ghostty';};
        };
      "keltonbassingthwaite@kelton-mbp.cdl.local" = let
        system = "aarch64-darwin";
        pkgs = nixpkgs.legacyPackages.${system};
        dagPkgs = dagger.packages.${system};
        hmm' = hmm.packages.${system}.hmm;
        wezterm' = wezterm-flake.packages.${system}.default;
        ghostty' = ghostty.packages.${system}.default;
      in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            ./darwin/home.nix
          ];
          extraSpecialArgs = {inherit dagPkgs hmm' wezterm' ghostty' mac-app-util;};
        };
    };
  };
}
