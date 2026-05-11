{ inputs, ... }:
{

  flake-file.inputs = {
    vicinae.url = "github:vicinaehq/vicinae";
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  apps.vicinae = {
    homeManager =
      { ... }:
      {
        imports = [ inputs.vicinae.homeManagerModules.default ];

        services.vicinae = {
          enable = true;
          systemd = {
            enable = true;
            autoStart = true;

          };
        };

        programs.niri = {
          settings = {
            binds."alt+space" = {
              action.spawn = [
                "vicinae"
                "toggle"
              ];
              repeat = false;
            };
          };
          # spawn-at-startup "vicinae" "server"
          # Alt+Space repeat=false { spawn "vicinae" "toggle"; }
        };
      };
  };
}
