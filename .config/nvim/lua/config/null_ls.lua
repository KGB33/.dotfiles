local null_ls = require("null-ls")

local sources = {
	-- Formatting
	null_ls.builtins.formatting.black,
	null_ls.builtins.formatting.isort,
	null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.stylua,
	null_ls.builtins.formatting.cue_fmt,
	null_ls.builtins.formatting.gofmt,
	null_ls.builtins.formatting.google_java_format,
	null_ls.builtins.formatting.prettier,



	-- Diagnostics
	null_ls.builtins.diagnostics.ansiblelint,
	null_ls.builtins.diagnostics.codespell,
    null_ls.builtins.diagnostics.eslint,
	null_ls.builtins.diagnostics.luacheck,

}

null_ls.setup({
	sources = sources,
})
