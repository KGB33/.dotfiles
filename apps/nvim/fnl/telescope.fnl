((. (require :telescope) :setup)
 {:extensions { :ui-select (. (require :telescope.themes) :get_dropdown) }
  :defaults {
    :path_display [:smart]
    :mappings {:i {:<C-u> false :<C-p> false}}
    }
  }
)


;; Load extensions
(fn loadExtn [extn] (
    pcall (. (require :telescope) :load_extension) extn))

(each [_ extn (pairs [
    :fzf
    :ui-select
    :dap
])] (loadExtn extn))


;; Set keymaps
(fn setKeymap [mode keys cmd opts] (
  vim.keymap.set mode keys (. (require :telescope.builtin) cmd) opts))

(each [_ [mode keys cmd opts] (pairs [
  [:n :<leader>tr :lsp_references { :desc "LSP [R]eferances"}]
  [:n :<leader>td :diagnostics { :desc "LSP [D]iagnostics"}]
  [:n :<leader>tf :find_files { :desc "Find [F]iles"}]
  [:n :<leader>tg :live_grep { :desc "Live [G]rep"}]
  [:n :<leader>tw :grep_string { :desc "Find [W]ord"}]
  [:n :<leader>tb :builtin { :desc "[T]elescope [B]uiltins"}]
])] (setKeymap mode keys cmd opts))
