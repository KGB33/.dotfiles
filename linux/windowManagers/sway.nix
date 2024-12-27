{
  config,
  lib,
  ...
}: {
  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      gaps = {
        smartGaps = true;
        smartBorders = "on";
      };
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in
        lib.mkOptionDefault {
          "${mod}+r" = "exec fuzzel";
          "${mod}+g" = "exec ghostty";
          "${mod}+l" = "exec hyprlock";
        };
      startup = [
        {
          command = "eww daemon";
        }
        {
          command = "eww open top_bar";
        }
      ];
      bars = [];
    };
  };
}
