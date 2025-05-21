return {
  'MeanderingProgrammer/render-markdown.nvim',
  config = function()
    require('render-markdown').setup({
      completions = { lsp = { enabled = true } },
    })
  end,
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }
}
