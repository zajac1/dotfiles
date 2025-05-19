local lsp_config = require "lspconfig"
local cmp_lsp = require "cmp_nvim_lsp"
local mason = require "mason"
local mason_lsp_config = require "mason-lspconfig"

-- taken from: https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = args.data.client_id }
      end,
    })
  end
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = "󰋼 ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
})

mason.setup();
mason_lsp_config.setup();
mason_lsp_config.setup_handlers {
  function(server_name)
    lsp_config[server_name].setup {
      capabilities = cmp_lsp.default_capabilities()
    }
  end,
}
