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
    nixos =
      { ... }:
      {
        nix.settings = {
          extra-substituters = [ "https://vicinae.cachix.org" ];
          extra-trusted-public-keys = [ "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc=" ];
        };
      };
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.vicinae.homeManagerModules.default ];

        services.vicinae = {
          enable = true;
          systemd = {
            enable = true;
            autoStart = true;
          };
          extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
            niri
            nix
            podman
            power-profile
            pulseaudio

          ];
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
        };
      };
  };
}
