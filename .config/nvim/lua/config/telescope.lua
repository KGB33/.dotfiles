-- *^*^*^*^* Setup *^*^*^*^* -- 
require("telescope").setup{
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown {}
		}
	},
	defaults = {
	 	path_display={"smart"},
	},
}


-- *^*^*^*^* Extensions *^*^*^*^* -- 
require("telescope").load_extension("ui-select")
require('telescope').load_extension('dap')
require("telescope").load_extension('gradle')

-- *^*^*^*^* Keybinds *^*^*^*^* -- 

-- Dap Keybinds
vim.api.nvim_set_keymap("n", "<Leader>td", ':Telescope dap commands<Enter>', {noremap=true})
vim.api.nvim_set_keymap("n", "<Leader>tb", ':Telescope dap list_breakpoints<Enter>', {noremap=true})

-- Open Telescope
vim.api.nvim_set_keymap("n", "<Leader>t", ':Telescope<Enter>', {noremap=true})

-- change default (?) spell_suggest to use Telescope window
vim.api.nvim_set_keymap("n", "z=", ":Telescope spell_suggest<Enter>", {noremap=true})

-- Find string under cursor in cwd
vim.api.nvim_set_keymap("n", "gs", ':lua require("telescope.builtin").grep_string()<Enter>', {noremap=true})

-- goto definition
vim.api.nvim_set_keymap("n", "gd", ':lua require("telescope.builtin").lsp_definitions()<Enter>', {noremap=true})
vim.api.nvim_set_keymap("n", "gt", ':lua require("telescope.builtin").lsp_type_definitions()<Enter>', {noremap=true})

-- Preform LSP code actions
vim.api.nvim_set_keymap("n", "<Leader>a", ':lua require("telescope.builtin").lsp_code_actions()<Enter>', {noremap=true})
vim.api.nvim_set_keymap("v", "<Leader>a", ':Telescope lsp_range_code_actions<Enter>', {noremap=true}) -- Still in vim CMD form so the visual range is passed

