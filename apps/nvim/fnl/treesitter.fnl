;; treesitter needs to be started after the filetype has been set

(vim.api.nvim_create_autocmd :FileType
                             {:pattern "*"
                              :callback (fn []
                                          (vim.treesitter.start)
                                          (set vim.wo.foldexpr
                                               "v:lua.vim.treesitter.foldexpr()")
                                          (set vim.wo.foldmethod :expr)
                                          (set vim.bo.indentexpr
                                               "v:lua.require'nvim-treesitter'.indentexpr()"))})
