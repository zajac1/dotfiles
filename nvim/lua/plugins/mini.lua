return {
  {
    'echasnovski/mini.surround',
    opts = {
      mappings = {
        replace = 'sc', -- Replace surrounding
      }
    },
    version = '*'
  },
  {
    'echasnovski/mini.animate',
    version = '*',
    config = function()
      require('mini.animate').setup()
    end
  }
} 
