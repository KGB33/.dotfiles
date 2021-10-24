-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.termguicolors=true
vim.o.laststatus=2 -- Status line is Always on
vim.o.completeopt = "menu,menuone,noselect" -- Required for hrsh7th/nvim-cmp
--vim.o.python_highlight_all=1
vim.cmd "syntax on"

-- leader
local leader = ','
vim.g.leader = leader
vim.g.localleader = leader
vim.g.mapleader = leader

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
local nvim_lsp = require('lspconfig')
local servers = { 'pyright', 'bashls', 'dockerls', 'gopls', 'tsserver', }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
end

-- Source configuration files
require'config/texlab'
require'config/cmp'
require'config/gopls'
require'config/galaxyline'

-- Explicitly disable the providers in the health#providers#check
vim.g.loaded_python_provider = 0 -- Python 2
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
