-- gruvbox-material stettings
local gruvbox_material_globals = {
    gruvbox_material_background = "hard",
    gruvbox_material_foreground = "mix",
    gruvbox_material_statusline_style = "mix",
    gruvbox_material_transparent_background = 2, -- yes + status line
    gruvbox_material_dim_inactive_windows = 1,
    gruvbox_material_visual = "reverse",
    gruvbox_material_menu_selection_background = "green",
    gruvbox_material_ui_contrast = "high",
    gruvbox_material_diagnogstic_virtual_text = "colored",
}

for k, v in pairs(gruvbox_material_globals) do
    vim.g[k] = v
end

vim.cmd.colorscheme("gruvbox-material")
