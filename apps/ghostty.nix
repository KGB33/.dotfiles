{
  lib,
  pkgs,
  config,
  ...
}: {
  options.apps.ghostty.enable = lib.mkEnableOption "ghostty" // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.ghostty.enable {
    programs.ghostty = {
      enable = true;
    };
  };
}
