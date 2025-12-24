(local avante-lib (require :avante_lib))
(local avante (require :avante))

(avante-lib.load)

(avante.setup {:auto_suggestions_provider :ollama
               :debug true
               :provider :ollama
               :providers {:ollama {:model :qwen3-coder}}})
