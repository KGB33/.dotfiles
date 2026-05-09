; (local wez (require :wezterm))
(local mod {})

(local extra_select_patterns ["v\\d{4}-\\d{2}-\\d{2}-\\d+"])

(fn mod.apply [cfg]
  (doto cfg
    (tset :audible_bell :Disabled)
    (tset :enable_tab_bar false)
    (tset :quick_select_alphabet :dvorak)
    (tset :quick_select_patterns extra_select_patterns)
    (tset :quick_select_remove_styling true)
    (tset :term :wezterm)))

mod
