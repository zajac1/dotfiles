return {
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
}
