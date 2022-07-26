-- *^*^*^*^* Setup *^*^*^*^* --
require("telescope").setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
	defaults = {
		path_display = { "smart" },
	},
})

-- *^*^*^*^* Extensions *^*^*^*^* --
require("telescope").load_extension("ui-select")
require("telescope").load_extension("dap")

-- *^*^*^*^* Keybinds *^*^*^*^* --

-- Dap Keybinds
vim.api.nvim_set_keymap("n", "<Leader>td", "<Cmd>Telescope dap commands<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader>tb", "<Cmd>Telescope dap list_breakpoints<CR>", { noremap = true })

-- Open Telescope
vim.api.nvim_set_keymap("n", "<Leader>t", "<Cmd>Telescope<CR>", { noremap = true })

-- Open find-files picker
vim.api.nvim_set_keymap("n", "<Leader>fz", '<Cmd>lua require("telescope.builtin").find_files()<CR>', { noremap = true })

-- change default (?) spell_suggest to use Telescope window
vim.api.nvim_set_keymap("n", "z=", "<Cmd>Telescope spell_suggest<CR>", { noremap = true })

-- Find string under cursor in cwd
vim.api.nvim_set_keymap("n", "gs", '<Cmd>lua require("telescope.builtin").grep_string()<CR>', { noremap = true })

-- goto definition
vim.api.nvim_set_keymap("n", "gd", '<Cmd>lua require("telescope.builtin").lsp_definitions()<CR>', { noremap = true })
vim.api.nvim_set_keymap(
	"n",
	"gt",
	'<Cmd>lua require("telescope.builtin").lsp_type_definitions()<CR>',
	{ noremap = true }
)
