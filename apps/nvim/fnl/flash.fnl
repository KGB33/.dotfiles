(local flash (require :flash))

(vim.keymap.set :n :<leader>fj (fn [] (flash.jump)) {:desc "[F]lash [J]upm"})
(vim.keymap.set :n :<leader>fs (fn [] (flash.treesitter_search))
                {:desc "[F]lash treesitter [S]earch"})

(vim.keymap.set :n :<leader>ft (fn [] (flash.treesitter))
                {:desc "[F]lash [T]reesitter"})
