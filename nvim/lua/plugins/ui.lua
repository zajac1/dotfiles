return {
  -- Theme
  {
    "Rigellute/shades-of-purple.vim",
    name = "Shades of Purple",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme "shades_of_purple"

      -- Make background transparent
      vim.cmd('highlight Normal guibg=none ctermbg=none')
      vim.cmd('highlight LineNr guibg=none ctermbg=none')
      vim.cmd('highlight Folded guibg=none ctermbg=none')
      vim.cmd('highlight NonText guibg=none ctermbg=none')
      vim.cmd('highlight SpecialKey guibg=none ctermbg=none')
      vim.cmd('highlight VertSplit guibg=none ctermbg=none')
      vim.cmd('highlight SignColumn guibg=none ctermbg=none')
      vim.cmd('highlight EndOfBuffer guibg=none ctermbg=none')
      vim.cmd('highlight NormalNC guibg=none ctermbg=none')
      vim.cmd('highlight StatusLineNC guibg=none ctermbg=none')
      vim.cmd('highlight VertSplitNC guibg=none ctermbg=none')
      vim.cmd('highlight FoldColumn guibg=none ctermbg=none')
      vim.cmd('highlight Pmenu guibg=none ctermbg=none')
    end
  },

  -- Tab bar
  {
    'romgrk/barbar.nvim',
    config = function()
      require("plugin-configs.barbar")
    end,
    dependencies = {
      'lewis6991/gitsigns.nvim',     -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
  },

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local shades_of_purple = {
        normal = {
          a = { fg = '#1e1e3f', bg = '#c792ea', gui = 'bold' },
          b = { fg = '#c792ea', bg = '#2d2b55' },
          c = { fg = '#a599e9', bg = '#1e1e3f' },
        },
        insert = {
          a = { fg = '#1e1e3f', bg = '#21c7a8', gui = 'bold' },
          b = { fg = '#21c7a8', bg = '#2d2b55' },
        },
        visual = {
          a = { fg = '#1e1e3f', bg = '#f07178', gui = 'bold' },
          b = { fg = '#f07178', bg = '#2d2b55' },
        },
        replace = {
          a = { fg = '#1e1e3f', bg = '#ffcb6b', gui = 'bold' },
          b = { fg = '#ffcb6b', bg = '#2d2b55' },
        },
        command = {
          a = { fg = '#1e1e3f', bg = '#82aaff', gui = 'bold' },
          b = { fg = '#82aaff', bg = '#2d2b55' },
        },
        inactive = {
          a = { fg = '#a599e9', bg = '#1e1e3f', gui = 'bold' },
          b = { fg = '#a599e9', bg = '#1e1e3f' },
          c = { fg = '#a599e9', bg = '#1e1e3f' },
        },
      }

      require('lualine').setup({
        sections = {
          lualine_x = { 'filetype' },
        },
        options = {
          theme = shades_of_purple,
        },
      })
    end
  },

  -- UI improvements
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      cmdline = {
        format = {
          search_down = { icon = '' } }
      },
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
          ["vim.lsp.buf.code_action"] = true
        },
      },
      presets = {
        bottom_search = false,        -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    }
  },

  -- Color picker and converter
  {
    'uga-rosa/ccc.nvim',
    opts = {
      highlighter = {
        auto_enable = true,
        lsp = true,
      }
    }
  },
}

