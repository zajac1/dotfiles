local lsp = require('lsp-zero')
local lspconfig = require("lspconfig")

local function on_attach(client, bufnr)
  if client.name == "eslint" then
    -- Use EslintFixAll for ESLint
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  else
    -- Use LSP formatting for other formatters (Biome, Prettier, etc.)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end
end

lsp.preset('recommended')

vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Preview symbol definition' })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, { desc = 'Go to type definition' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Show references' })
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, { desc = 'Show signature help' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Show warnings & errors for current buffer' })

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

local lua_opts = lsp.nvim_lua_ls()

lspconfig.biome.setup({ on_attach = on_attach })
lspconfig.eslint.setup({ on_attach = on_attach })
lspconfig.svelte.setup({ on_attach = on_attach })
lspconfig.cssls.setup({ on_attach = on_attach })
lspconfig.lua_ls.setup(lua_opts)
lsp.setup()

