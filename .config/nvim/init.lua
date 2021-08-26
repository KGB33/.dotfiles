-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.termguicolors=true
vim.o.laststatus=2 -- Status line is Always on
vim.o.completeopt = "menuone,noselect" -- Required for hrsh7th/nvim-compe
--vim.o.python_highlight_all=1
vim.cmd "syntax on"

-- leader
vim.g.leader = ','
vim.g.localleader = ','

-- Plugins 
require('plugins')

-- Theme
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

-- nvim Python Path
vim.g.python3_host_prog = '~/.config/nvim/.venv/bin/python'

-- Spelling
vim.o.spell = true
vim.o.spelllang = "en_us"

-- LSP
require'lspconfig'.pyright.setup{}  -- community/pyright
require'lspconfig'.bashls.setup{}   -- community/bash-language-server
require'lspconfig'.dockerls.setup{} -- npm install -g dockerfile-language-server-nodejs
require'lspconfig'.gopls.setup{}    -- community/gopls 
require'plugin_config/gopls'
require'lspconfig'.tsserver.setup{}

-- Explicitly disable the providers in the health#providers#check
vim.g.loaded_python_provider = 0 -- Python 2
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
