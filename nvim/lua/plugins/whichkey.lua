local TIMEOUT_VALUE = 2000;
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = TIMEOUT_VALUE
  end,
  opts = {
    delay = TIMEOUT_VALUE,
  },
}
