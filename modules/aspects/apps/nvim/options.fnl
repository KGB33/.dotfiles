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

(set vim.o.termguicolors true)

(set vim.o.expandtab true)

(set vim.o.splitright true)
(set vim.o.splitbelow true)

(set vim.o.scrolloff 10)

(vim.keymap.set :n :j "v:count == 0 ? 'gj' : 'j'" {:expr true :silent true})
(vim.keymap.set :n :k "v:count == 0 ? 'gk' : 'k'" {:expr true :silent true})

(vim.keymap.set :n :<leader>do vim.diagnostic.open_float
                {:desc "Open diagnostic"})
(vim.keymap.set :n :<leader>ca vim.lsp.buf.code_action {:desc "Code Action"})

(vim.cmd "colorscheme catppuccin")
;; treesitter highlighting has to be 
;; started in each buf, but not all 
;; buffers have a parser
(vim.api.nvim_create_autocmd :FileType
                             {:pattern "*"
                              :callback (fn [ev]
                                          (let [ft (vim.filetype.match {:buf ev.buf})]
                                            (when (and ft
                                                       (vim.treesitter.language.add ft))
                                              (vim.treesitter.start ev.buf))))})

(set vim.o.foldmethod :expr)
(set vim.o.foldexpr "v:lua.vim.treesitter.foldexpr()")
(set vim.opt.foldenable false)
