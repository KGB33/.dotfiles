function open_pdf()
	local fullPath = vim.fn.expand("%:p")
	local pdfPath, _ = fullPath:gsub(".tex", ".pdf")
	vim.cmd(string.format("silent !zathura %s &",pdfPath))
end

local vimp = require('vimp')

vimp.nnoremap('<leader>z', open_pdf)
