local flash = require("flash");

flash.toggle(true);

vim.keymap.set('n', '<leader>fj', function() flash.jump() end, { desc = '[F]lash [J]upm' })
vim.keymap.set('n', '<leader>fs', function() flash.treesitter_search() end, { desc = '[F]lash treesitter [S]earch' })
vim.keymap.set('n', '<leader>ft', function() flash.treesitter() end, { desc = '[F]lash [T]reesitter' })
