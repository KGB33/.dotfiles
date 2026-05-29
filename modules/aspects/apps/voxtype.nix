{ inputs, ... }:
{
  flake-file.inputs.voxtype = {
    url = "github:peteonrails/voxtype";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.voxtype = {
    homeManager =
      { pkgs, ... }:
      let
        voxtype' = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in
      {
        imports = [ inputs.voxtype.homeManagerModules.default ];

        programs.voxtype = {
          enable = true;
          package = voxtype';
          settings = {
            whisper.model = "small.en";
          };
          service.enable = true;
        };

        programs.niri.settings.binds."Mod+T" = {
          action.spawn = [
            "voxtype"
            "record"
            "toggle"
          ];
        };
      };
  };
}
