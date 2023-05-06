-- Bootstrap Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- LSP & CMP
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-nvim-lua' },

            -- Snippets
            { 'L3MON4D3/LuaSnip' },
            { 'rafamadriz/friendly-snippets' },
        }
    },
    -- Tree-Sitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "IndianBoy42/tree-sitter-just",    build = ":lua require('tree-sitter-just').setup{}" },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/popup.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        }
    },

    -- Color schems
    {
        "sainnhe/gruvbox-material",
        lazy = false
    },
    -- Visuals
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
        options = { theme = "gruvbox-material" }
    },
    {
        "narutoxy/silicon.lua",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('silicon').setup({})
        end
    },
    { "axieax/typo.nvim" },


    {
        'phaazon/mind.nvim',
        branch = 'v2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require 'mind'.setup()
        end
    }
})
