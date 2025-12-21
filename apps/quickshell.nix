{
  lib,
  config,
  pkgs,
  ...
}: {
  options.apps.quickshell.enable = lib.mkEnableOption "quickshell"; # // {default = pkgs.stdenv.isLinux;};

  config = lib.mkIf config.apps.quickshell.enable {
    programs.quickshell = {
      enable = true;
      systemd.enable = true;
      configs = {
        "shell.qml" = ./quickshell/shell.qml;
      };
    };
  };
}
