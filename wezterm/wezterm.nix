{wezterm', ...}: {
  programs.wezterm = {
    enable = true;
    package = wezterm';
    extraConfig = builtins.readFile ./wezterm.lua;
  };
}
