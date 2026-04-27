return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    ---@module 'snacks' 
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  init = function()
    local cmd = "opencode --port"
    ---@type snacks.terminal.Opts
    local terminal_opts = {
      win = {
        position = "float",
        width = 0.8,
        height = 0.8,
        border = "rounded",
        title = " OpenCode ",
        title_pos = "center",
        bo = { filetype = "snacks_terminal" },
      },
    }
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      server = {
        start = function()
          require("snacks.terminal").open(cmd, terminal_opts)
        end,
        stop = function()
          local term = require("snacks.terminal").get(cmd, vim.tbl_extend("force", terminal_opts, { create = false }))
          if term then term:close() end
        end,
        toggle = function()
          require("snacks.terminal").toggle(cmd, terminal_opts)
        end,
      },
    }
  end,
  config = function()
    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<D-o>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
  end,
}
