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

        home.packages = with pkgs; [ pulseaudio ];

        programs.vicinae = {
          enable = true;
          systemd.enable = false;
          extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
            niri
            nix
            podman
            power-profile
            pulseaudio
          ];
        };

        wayland.windowManager.niri.settings = {
          _children = [
            {
              spawn-at-startup = [
                "vicinae"
                "server"
              ];
            }
          ];

          binds."alt+space" = {
            _props.repeat = false;
            spawn = [
              "vicinae"
              "toggle"
            ];
          };
        };
      };
  };
}
