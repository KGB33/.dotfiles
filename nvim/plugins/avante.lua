-- https://github.com/yetone/avante.nvim
require('avante_lib').load()

require('avante').setup({
    auto_suggestions_provider = "ollama",
    debug = true,
    provider = "ollama",
    ollama = {
        -- model = "qwen2.5-coder:7b",
        -- model = "gemma3:12b",
        model = "qwen3:30b",
    },
})
