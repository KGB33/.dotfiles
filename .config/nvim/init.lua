-- Leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Plugins
require("plugins")
require("config/treesitter")
require("config/telescope")
require("config/lualine")


-- Keybinds
require("keybinds")

-- Themes
vim.o.termguicolors = true
vim.o.background = "dark"
vim.o.gruvbox_material_better_performance = 1
vim.o.gruvbox_material_foreground = "mix"
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_transparent_background = 2
vim.g.gruvbox_material_dim_inactive_windows = 1
vim.cmd([[colorscheme gruvbox-material]])
vim.o.laststatus = 3
vim.o.signcolumn = "yes"

-- LSP
local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.setup()

-- Langage Providers
vim.g.python3_host_prog = "~/.config/nvim/.venv/bin/python"
vim.g.loaded_python_provider = 0;
vim.g.loaded_perl_provider = 0;
vim.g.loaded_ruby_provider = 0;
vim.g.loaded_node_provider = 0;


-- Spelling
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.spelloptions = "camel"

-- Other Options
vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
