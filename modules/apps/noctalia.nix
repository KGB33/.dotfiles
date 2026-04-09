{inputs, ...}: {
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia-shell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.noctalia = {...}: {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {};
    };
  };
}
