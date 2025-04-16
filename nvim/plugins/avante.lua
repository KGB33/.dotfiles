-- https://github.com/yetone/avante.nvim
require('avante_lib').load()

-- Ollama API Documentation https://github.com/ollama/ollama/blob/main/docs/api.md#generate-a-completion
local role_map = {
    user = "user",
    assistant = "assistant",
    system = "system",
    tool = "tool",
}

require('avante').setup({
    auto_suggestions_provider = "ollama",
    debug = true,
    provider = "ollama",
    ollama = {
        -- model = "qwen2.5-coder:7b",
        model = "gemma3:12b",
    },
})
