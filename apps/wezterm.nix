{
  lib,
  config,
  ...
}: {
  options.apps.wezterm.enable = lib.mkEnableOption "wezterm" // {default = true;};

  config = lib.mkIf config.apps.wezterm.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm/wezterm.lua;
    };
  };
}
