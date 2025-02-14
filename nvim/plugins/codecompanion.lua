local jit = require "jit";

require("codecompanion").setup({
    strategies = {
        chat = {
            adapter = "qwen",
        },
        inline = {
            adapter = "qwen",
        },
    },
    adapters = {
        qwen = function()
            return require("codecompanion.adapters").extend("ollama", {
                name = "qwen",
                schema = {
                    model = {
                        default = get_model(),
                    },
                },
            })
        end,
    },

})

function get_model()
    if jit.os == "OSX" then
        return "qwen2.5-coder:3b"
    end

    return "qwen2.5-coder:0.5b"
end
