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
    config = function() require'galaxyline_config' end,
    -- some optional icons
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
}


end)
