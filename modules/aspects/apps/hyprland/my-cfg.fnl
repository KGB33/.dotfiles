(hl.bind "SUPER + G" (hl.dsp.exec_cmd "wezterm"))
(hl.bind "SUPER + B" (hl.dsp.exec_cmd "firefox"))
(hl.bind "ALT + SPACE" (hl.dsp.exec_cmd "vicinae toggle"))

(hl.gesture { :fingers 3 :direction :horizontal :action :workspace})

(hl.config {
  :general {:layout :scrolling}
           })
