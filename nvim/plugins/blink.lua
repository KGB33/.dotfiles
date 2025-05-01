local blink = require("blink.cmp")
blink.setup({
    sources = {
        default = { 'avante', 'lsp', 'path', 'buffer' },
        providers = {
            avante = {
                module = 'blink-cmp-avante',
                name = 'Avante',
            }
        },
    },
    keymap = { preset = "default" },
    completion = {
        accept = { auto_brackets = { enabled = false }, },
    },
})
