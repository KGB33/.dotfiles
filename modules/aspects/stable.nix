{ inputs, ... }:
{
  flake-file.inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";
  };

  den.aspects.stable =
    let
      stableMod = {
        nixpkgs.overlays = [
          (_final: prev: {
            stable = import inputs.nixpkgs-stable {
              inherit (prev.stdenv.hostPlatform) system;
              config = {
                allowUnfree = prev.config.allowUnfree or false;
                allowUnfreePredicate = prev.config.allowUnfreePredicate or (_: false);
              };
            };
          })
        ];
      };
    in
    {
      nixos = stableMod;
      homeManager = stableMod;
    };
}
