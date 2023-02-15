local options = {
    spell = true,
    spelllang = "en_us",
    spelloptions = "camel",
    number = true,
    relativenumber = true,
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,
    expandtab = true,
    autoindent = true,
    smartindent = true,
    termguicolors = true,
    background = "dark",
    laststatus = 3,
    signcolumn = "yes",
}

for k, v in pairs(options) do
    vim.opt[k] = v
end
