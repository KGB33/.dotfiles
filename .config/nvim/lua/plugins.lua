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
  use {'nvim-telescope/telescope-ui-select.nvim' }

  -- Gruvbox
  use {"npxbr/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}

  -- Statusline
  use {
	  'nvim-lualine/lualine.nvim',
	  requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  -- Builtin LSP
  use 'neovim/nvim-lspconfig'
  use 'neovim/nvim-lsp'
  -- Debuggers
  use {'mfussenegger/nvim-dap',
  	requires = {'nvim-telescope/telescope-dap.nvim', "rcarriga/nvim-dap-ui"}
  }

  -- Auto-complete
  use {'hrsh7th/nvim-cmp',
  		requires={
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'octaltree/cmp-look',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-calc',
			'hrsh7th/cmp-vsnip',
			'hrsh7th/vim-vsnip'
			},
  		config = function() require'config/cmp' end}
  
  use 'svermeulen/vimpeccable'

  -- Java (yuck)
  -- Also download & extract the latest jndi lsp to `~/.config/nvim/.jdtls/`
  -- https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
  use 'mfussenegger/nvim-jdtls'

  -- Better movement
  use 'ggandor/lightspeed.nvim'

end)
