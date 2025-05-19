vim.cmd [[packadd packer.nvim]]

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/plenary.nvim' } }
  }

  use { "catppuccin/nvim", as = "catppuccin" }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  use({
    "stevearc/oil.nvim",
    config = function()
      require("oil").setup()
    end,
  })

  use 'lewis6991/gitsigns.nvim' -- OPTIONAL: for git status
  use 'romgrk/barbar.nvim'
  use 'mbbill/undotree'
  use 'kyazdani42/nvim-web-devicons'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'echasnovski/mini.animate'
  use 'echasnovski/mini.surround'
  use { 'folke/noice.nvim', requires = { 'MunifTanjim/nui.nvim' } }
  use { 'folke/which-key.nvim' }
  use 'numToStr/Comment.nvim'
  use "smartpde/telescope-recent-files"
  use {
    'rmagatti/auto-session',
    config = function()
      require("auto-session").setup()
    end
  }
  use({
    "kdheepak/lazygit.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
  })

  use({
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  })

  use('onsails/lspkind.nvim');
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'nvim-telescope/telescope-ui-select.nvim' }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use {
    'akinsho/git-conflict.nvim', config = function()
    require('git-conflict').setup()
  end
  }

  use {
    'uga-rosa/ccc.nvim', config = function()
    require('ccc').setup({
      highlighter = {
        auto_enable = true,
        lsp = true,
      }
    })
  end
  }

  use {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    config = function()
      require('lazydev').setup({
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      })
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)
