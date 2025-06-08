-- Set "<space>" as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '


-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Better Colors
vim.o.termguicolors = true

-- Tabs/Spaces
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Sane Splits
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.scrolloff = 10


-- Set bang shell to non-NuShell shell
vim.o.shell = "zsh"

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
