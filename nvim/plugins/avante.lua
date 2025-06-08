-- https://github.com/yetone/avante.nvim
require('avante_lib').load()

require('avante').setup({
    auto_suggestions_provider = "ollama",
    debug = true,
    provider = "ollama",
    providers = {
        ollama = {
            model = "devstral",
        },
    }
})
