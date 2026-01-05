(set vim.g.mapleader " ")
(set vim.g.maplocalleader " ")

(set vim.o.breakindent true)

(set vim.o.undofile true)
(set vim.o.swapfile false)

(set vim.o.hlsearch false)
(set vim.o.ignorecase true)
(set vim.o.smartcase true)

(set vim.wo.number true)
(set vim.wo.relativenumber true)
(set vim.wo.signcolumn :yes)

(set vim.o.updatetime 250)
(set vim.o.timeoutlen 300)

(set vim.o.completeopt "menuone,noselect")

(set vim.o.termguicolors true)

(set vim.o.tabstop 4)
(set vim.o.shiftwidth 4)
(set vim.o.expandtab true)

(set vim.o.splitright true)
(set vim.o.splitbelow true)

(set vim.o.scrolloff 10)

(vim.keymap.set :n :j "v:count == 0 ? 'gj' : 'j'" {:expr true :silent true})
(vim.keymap.set :n :k "v:count == 0 ? 'gk' : 'k'" {:expr true :silent true})

(vim.filetype.add {:extension {:ncl :nickel}})
