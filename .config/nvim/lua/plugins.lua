-- Bootstrap packer (https://github.com/wbthomason/packer.nvim#bootstrapping)
local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

return require('packer').startup(function()
  -- Used to make sure stuff is loaded correctly
  use 'tjdevries/astronauta.nvim'
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Python Autoformatting
  use 'psf/black'

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim',
  	requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}
  }

  -- Gruvbox
  use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

  -- Airline
  use {'vim-airline/vim-airline', requires='vim-airline/vim-airline-themes'}

  -- Statusline
  use {
  'glepnir/galaxyline.nvim',
    branch = 'main',
    -- your statusline
    config = function() require'config/galaxyline' end,
    -- some optional icons
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
}

  -- Builtin LSP
  use 'neovim/nvim-lspconfig'
  use 'neovim/nvim-lsp'

  -- Auto-complete
  use {'hrsh7th/nvim-cmp',
  		requires={
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'octaltree/cmp-look',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-calc',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip'},
  		config = function() require'config/cmp' end}
  
  use 'svermeulen/vimpeccable'

  -- Java (yuck)
  -- Also install `aur/jdtls`
  use 'mfussenegger/nvim-jdtls'


end)
