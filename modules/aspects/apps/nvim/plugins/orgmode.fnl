(local org (require :orgmode))

(local templates {:p {:description :Promps
                      :template "* [[%x][%(return string.match('%x', '([^/]+)$'))]]%?"
                      :target "~/org/repos.org"}})

(org.setup {:org_agenda_files "~/orgfiles/**/*"
            :org_default_notes_file "~/orgfiles/refile.org"
            :org_capture_templates templates})

(vim.lsp.enable :org)
