{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.nyxt.enable = lib.mkEnableOption "Nyxt" // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.nyxt.enable {
    programs.nyxt = {
      enable = true;
    };
  };
}
