(hl.monitor {:output "DP-1"
             :mode "highrr"
             :position "0x0"
             :scale 1})

(hl.bind "SUPER + G" (hl.dsp.exec_cmd "wezterm"))
(hl.bind "SUPER + B" (hl.dsp.exec_cmd "firefox"))
(hl.bind "ALT + SPACE" (hl.dsp.exec_cmd "vicinae toggle"))

(for [i 1 9]
  (hl.bind (.. "SUPER + " i) (hl.dsp.focus {:workspace i}))
  (hl.bind (.. "SUPER + SHIFT + " i) (hl.dsp.window.move {:workspace i})))

(hl.on :hyprland.start (fn [] (hl.exec_cmd :noctalia-shell)))
