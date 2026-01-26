{
  pkgs,
  lib,
  config,
  ...
}: {
  options.apps.noctalia.enable = lib.mkEnableOption "noctalia" // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.noctalia.enable {
    programs.noctalia-shell = {
      enable = true;
      systemd.enable = true;
      settings = {};
    };
  };
}
