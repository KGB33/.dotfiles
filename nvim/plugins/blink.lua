local blink = require("blink.cmp")
blink.setup({
    keymap = { preset = "default" },
    completion = {
        accept = { auto_brackets = { enabled = false }, },
    },
})
