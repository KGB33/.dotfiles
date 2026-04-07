(local avante-lib (require :avante_lib))
(local avante (require :avante))

(avante-lib.load)

(avante.setup {:auto_suggestions_provider :ollama
               :debug true
               :provider :claude-code
               :providers {:ollama {:model :qwen3-coder}}
               :acp_providers {:claude-code {:command :npx
                                             :args ["@zed-industries/claude-code-acp"]
                                             :env {:NODE_NO_WARNINGS :1
                                                   :ANTHROPIC_API_KEY (os.getenv :ANTHROPIC_API_KEY)}}}})
