return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "javascript", "typescript", "tsx",
      "lua", "vim", "vimdoc", "query",
      "markdown", "markdown_inline",
      "regex", "json", "yaml", "html", "css",
      "bash", "diff", "gitcommit",
    }

    require("nvim-treesitter").install(parsers)

    local ts_filetypes = {
      "javascript", "javascriptreact",
      "typescript", "typescriptreact",
      "lua", "vim", "help", "query",
      "markdown",
      "json", "yaml", "html", "css",
      "sh", "bash", "diff", "gitcommit",
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = ts_filetypes,
      callback = function()
        pcall(vim.treesitter.start)
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
      end,
    })
  end,
}
