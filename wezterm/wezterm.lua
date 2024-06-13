local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Everforest Dark (Gogh)'

config.enable_tab_bar = false

config.font = wezterm.font 'FiraCode Nerd Font'

return config
