local blink = require("blink.cmp")
blink.setup({
    fuzzy = {
        implementation = "prefer_rust_with_warning",
        prebuilt_binaries = {
            download = false,
        },
    },
    sources = {
        default = { 'lsp', 'path', 'buffer' },
    },
    keymap = { preset = "default" },
    completion = {
        accept = { auto_brackets = { enabled = false }, },
    },
})
