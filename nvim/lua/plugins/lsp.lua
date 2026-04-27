return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", lazy = false, opts = {} },
      { "neovim/nvim-lspconfig" },
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "onsails/lspkind.nvim",
          "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
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
        end
      }
    },
    config = function()
      require("mason-lspconfig").setup()

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("lsp-format-on-save", { clear = true }),
        callback = function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          local priority = { "oxfmt", "biome" }
          for _, name in ipairs(priority) do
            for _, client in ipairs(clients) do
              if client.name == name then
                vim.lsp.buf.format({ name = name, timeout_ms = 3000 })
                return
              end
            end
          end
        end,
      })

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "󰌵",
          },
        },
      })
    end
  },
}
