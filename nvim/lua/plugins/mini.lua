return {
  {
    'echasnovski/mini.surround',
    opts = {
      mappings = {
        replace = 'sc', -- Replace surrounding
      }
    },
  },
  {
    'echasnovski/mini.animate',
    config = function()
      require('mini.animate').setup()
    end
  }
} 
