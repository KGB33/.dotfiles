  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
		{name = 'buffer'},
		{name = 'nvim_lsp'},
        {name = "nvim_lua"},
		{name = "look"},
		{name = "path"},
		{name = "calc"}, 
		{name = "spell"},
    }
  })
