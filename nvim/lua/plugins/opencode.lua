return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks' 
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  init = function()
    vim.g.opencode_opts = {
      provider = {
        cmd = "opencode -c",
        snacks = {
          win = {
            position = "float",
            width = 0.8,
            height = 0.8,
            border = "rounded",
            enter = true,
            title = " OpenCode ",
            title_pos = "center",
          }
        }
      }
    }
  end,
  config = function()
    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<D-o>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
  end,
}
