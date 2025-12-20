{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.spotify.enable = lib.mkEnableOption "spotify" // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.spotify.enable {
    services.spotifyd = {
      enable = true;
    };

    programs.spotify-player = {
      enable = true;
    };
  };
}
