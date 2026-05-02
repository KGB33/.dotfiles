(local cmp (require :blink.cmp))

(cmp.setup {:completion {:menu {:draw {:treesitter [:lsp]}}
                         :ghost_text {:enabled true}}
            :signature {:enabled true}})
