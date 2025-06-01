local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'render_markdown' }
  },
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      preset = 'codicons',
      ellipsis_char = '…',
      show_labelDetails = true,
    })
  }
})
