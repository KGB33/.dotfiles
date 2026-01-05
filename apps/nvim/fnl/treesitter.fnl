;; TODO: Profile time
;; TODO: Memoization?
(fn hasParser? [ft]
  (let [lang (vim.treesitter.language.get_lang ft)]
    (and lang (pcall vim.treesitter.get_parser 0 lang))))

;; treesitter needs to be started after the filetype has been set
(vim.api.nvim_create_autocmd :FileType
                             {:pattern "*"
                              :callback (fn []
                                          (when (hasParser? vim.bo.filetype)
                                            (vim.treesitter.start)
                                            (set vim.wo.foldexpr
                                                 `"v:lua.vim.treesitter.foldexpr()")
                                            (set vim.wo.foldmethod :expr)
                                            (set vim.bo.indentexpr
                                                 "v:lua.require'nvim-treesitter'.indentexpr()")))})
