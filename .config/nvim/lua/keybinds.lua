-- Location for all non-plugin specific Keybinds.

-- Perform LSP code actions
vim.api.nvim_set_keymap("n", "<Leader>a", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { noremap = true })
vim.api.nvim_set_keymap("v", "<Leader>a", "<Cmd>lua vim.lsp.buf.range_code_action()<CR>", { noremap = true })

-- format
vim.api.nvim_set_keymap("n", "<Leader>f", "<Cmd>lua vim.lsp.buf.format { async = true } <CR>", { noremap = true })

-- diagnostics
vim.api.nvim_set_keymap("n", "<Leader>do", "<Cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>dn", "<Cmd>lua vim.diagnostic.goto_next()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>dp", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", { noremap = true })
