-- Leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Plugins
require("plugins")
require("config/treesitter")
require("config/telescope")


-- Keybinds
require("keybinds")

-- Themes
vim.cmd([[ colorscheme gruvbox]])

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
