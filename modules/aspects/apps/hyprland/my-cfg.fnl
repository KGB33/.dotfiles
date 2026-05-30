(hl.bind "SUPER + G" (hl.dsp.exec_cmd "wezterm"))
(hl.bind "SUPER + B" (hl.dsp.exec_cmd "firefox"))
(hl.bind "ALT + SPACE" (hl.dsp.exec_cmd "vicinae toggle"))

(hl.on :hyprland.start (fn [] (hl.exec_cmd :noctalia-shell)))
