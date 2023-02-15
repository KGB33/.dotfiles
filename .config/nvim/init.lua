-- Leader
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("plugins")
require("options")
require("globals")
require("keybinds")

require("config.treesitter")
require("config.telescope")
require("config.lualine")
require("config.theme")



-- LSP
local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.setup()

