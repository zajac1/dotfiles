return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", lazy = false, opts = {} },
      { "neovim/nvim-lspconfig" },
      {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
          library = {
            -- Load luvit types when the `vim.uv` word is found
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
          require("plugin-configs.cmp")
        end
      }
    },
    config = function()
      require("plugin-configs.lsp")
    end
  },
}
