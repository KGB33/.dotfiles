{...}: {
  wayland.windowManager.river = {
    enable = true;
    systemd.enable = true;
    settings = {
      declare-mode = ["Display"];
      map = {
        normal =
          {
            "-repeat None XF86AudioRaiseVolume" = "spawn 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+'";
            "-repeat None XF86AudioLowerVolume" = "spawn 'wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-'";
            "-repeat None XF86MonBrightnessUp" = "spawn 'brightnessctl s +5%'";
            "-repeat None XF86MonBrightnessDown" = "spawn 'brightnessctl s 5%-'";
            "None XF86AudioMute" = "spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'";

            # Spawns
            "Super R" = "spawn fuzzel";
            "Alt L" = "spawn hyprlock";
            "Super C" = "close";
            "Super+Shift S" = "spawn 'grim -g \"$(slurp -d)\" - | wl-copy'";

            # Meta
            "Super M" = "exit";
            "Super D" = "enter-mode Display";

            # Window Focus
            "Super H" = "focus-view left";
            "Super J" = "focus-view down";
            "Super K" = "focus-view up";
            "Super L" = "focus-view right";
            "Super N" = "focus-view next";
            "Super P" = "focus-view previous";

            # Window Movement
            "Super+Shift H" = "swap left";
            "Super+Shift J" = "swap down";
            "Super+Shift K" = "swap up";
            "Super+Shift L" = "swap right";
            "Super+Shift N" = "swap next";
            "Super+Shift P" = "swap previous";
            "Super Z" = "zoom";
          }
          // (
            # Tags
            let
              pow = exp:
                if exp == 0
                then 1
                else 2 * pow (exp - 1);
              str = builtins.toString;
            in
              builtins.listToAttrs (
                builtins.concatLists [
                  (builtins.genList (x: {
                      name = "Super ${str x}";
                      value = "set-focused-tags ${str (pow x)}";
                    })
                    9)
                  (builtins.genList (x: {
                      name = "Super+Shift ${str x}";
                      value = "set-view-tags ${str (pow x)}";
                    })
                    9)
                ]
              )
          );
        Display = {
          "None Escape" = "enter-mode normal";
          # Move
          "Super H" = "move left  100";
          "Super J" = "move down  100";
          "Super K" = "move up    100";
          "Super L" = "move right 100";
          # Snap
          "Shift H" = "snap left";
          "Shift J" = "snap down";
          "Shift K" = "snap up";
          "Shift L" = "snap right";
          # Resize
          "Super+Shift  H" = "resize horizontal -100";
          "Super+Shift  J" = "resize vertical    100";
          "Super+Shift  K" = "resize vertical   -100";
          "Super+Shift  L" = "resize horizontal  100";
        };
      };
      spawn = ["rivertile"];
      default-layout = "rivertile";
    };
  };
}
