{
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "eww open top_bar"
        "hyprpaper"
      ];
      monitor = [
        "eDP-2,preferred,auto,1"
        ",preferred,auto,1,mirror,eDP-2"
      ];
      decoration = {
        rounding = 5;
      };
      "$mod" = "SUPER";
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"

        # ", XF86AudioNext,"
        # ", XF86AudioPrev,"

        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];
      bind =
        [
          "$mod, M, exit"
          "$mod, F, exec, firefox"
          "$mod, Q, exec, kitty"
          "$mod, R, exec, fuzzel"
          "$mod, L, exec, hyprlock"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          '', Print, exec, grim -g "$(slurp -d)" - | wl-copy''
          ''$mod, Print, exec, grim -g "$(slurp -d)"''
          # ", XF86AudioPlay,"
          # ", XF86RFKill, " # Airplane mode
          # ", XF86Tools, " # Framework Icon
        ]
        ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList
            (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            )
            10)
        );
    };
  };
}
