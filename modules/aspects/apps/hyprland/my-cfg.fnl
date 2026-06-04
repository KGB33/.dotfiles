(hl.monitor {:output :DP-1 :mode :highrr :position :0x0 :scale 1})

(hl.bind "SUPER + G" (hl.dsp.exec_cmd :wezterm))
(hl.bind "SUPER + B" (hl.dsp.exec_cmd :firefox))
(hl.bind "ALT + SPACE" (hl.dsp.exec_cmd "vicinae toggle"))

(for [i 1 9]
  (hl.bind (.. "SUPER + " i) (hl.dsp.focus {:workspace i}))
  (hl.bind (.. "SUPER + SHIFT + " i) (hl.dsp.window.move {:workspace i})))

(hl.bind :XF86AudioRaiseVolume
         (hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
         {:locked true :repeating true})
(hl.bind :XF86AudioLowerVolume
         (hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-")
         {:locked true :repeating true})
(hl.bind :XF86AudioMute
         (hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
         {:locked true})
(hl.bind :XF86AudioMicMute
         (hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
         {:locked true})

(hl.bind :XF86AudioPlay (hl.dsp.exec_cmd "playerctl play-pause") {:locked true})
(hl.bind :XF86AudioNext (hl.dsp.exec_cmd "playerctl next") {:locked true})
(hl.bind :XF86AudioPrev (hl.dsp.exec_cmd "playerctl previous") {:locked true})
(hl.bind :XF86AudioStop (hl.dsp.exec_cmd "playerctl stop") {:locked true})

(hl.bind "SUPER + SHIFT + S" (hl.dsp.exec_cmd "grim -g \"$(slurp)\" - | wl-copy"))

(hl.on :hyprland.start (fn [] (hl.exec_cmd :noctalia-shell)))
