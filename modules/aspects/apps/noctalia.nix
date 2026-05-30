{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.noctalia = {
    homeManager = {pkgs, ...}: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia-shell = {
        enable = true;
      };

      programs.niri.settings.spawn-at-startup = [{command =["noctalia-shell"];}];
    };
  };


}
