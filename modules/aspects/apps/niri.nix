{inputs, ...}: {
  flake-file.inputs.niri = {
    url = "github:sodiboo/niri-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  apps.niri = {
    includes = let
      # TODO, refactor into its own module
      wezterm.homeManager = {...}: {
        programs.wezterm.enable = true;
      };
    in [wezterm];

    homeManager = {...}: {
      imports = [inputs.niri.homeModules.niri];

      programs.niri = {
        enable = true;
        settings = {
          binds = {
            "Mod+G".action.spawn = "wezterm";
            "Mod+F".action.spawn = "firefox";
          };
        };
      };
    };
  };
}
