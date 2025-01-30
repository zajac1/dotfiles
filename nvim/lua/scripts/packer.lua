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

  --[[ use({
    "neanias/everforest-nvim",
    config = function()
      require("everforest").setup()
    end,
  }) ]]

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

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim' },           -- Optional
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },     -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      { 'L3MON4D3/LuaSnip' },     -- Required
    }
  }

  use 'echasnovski/mini.animate'
  use 'echasnovski/mini.surround'
  use { 'folke/noice.nvim', requires = {
    'MunifTanjim/nui.nvim' } }
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
    -- optional for floating window border decoration
    requires = {
      "nvim-lua/plenary.nvim",
    },
  })

  use({
    'weilbith/nvim-code-action-menu',
    cmd = 'CodeActionMenu',
  })

  use('MunifTanjim/prettier.nvim')
  use('onsails/lspkind.nvim');
  use('ggandor/leap.nvim');
  --[[ use {
    "pmizio/typescript-tools.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup {}
    end,
  } ]]

  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {'nvim-telescope/telescope-ui-select.nvim' }

  use {
    'akinsho/git-conflict.nvim', config = function()
      require('git-conflict').setup()
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end)
