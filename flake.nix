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
  };

  outputs = { nixpkgs, home-manager, dagger, hmm, nasty, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      dagPkgs = dagger.packages.${system};
      hmm' = hmm.packages.${system}.hmm;
      nasty' = nasty.packages.${system}.nasty;
    in
    {
      homeConfigurations."kgb33" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit dagPkgs hmm' nasty'; };
      };
    };
}
