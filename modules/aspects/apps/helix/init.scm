(require-builtin steel/random as rand::)
(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/configuration.scm")
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-language "scheme"
                 (language-servers '("steel-language-server")))
