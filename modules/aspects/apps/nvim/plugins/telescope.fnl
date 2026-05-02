(local tele (require :telescope.builtin))

(vim.keymap.set :n :<leader>ff tele.find_files {:desc "Find Files"})
(vim.keymap.set :n :<leader>fg tele.live_grep {:desc "File Grep"})
(vim.keymap.set :n :<leader>fb tele.buffers {:desc "Find Buffers"})
(vim.keymap.set :n :<leader>fh tele.help_tags {:desc "Find Help Tags"})
(vim.keymap.set :n :<leader>fd tele.diagnostics {:desc "Find Diagnostics"})
