return {
  "tinted-theming/tinted-nvim",
  priority = 1000,
  config = function()
    require("tinted-nvim").setup({
      supports = {
        live_reload = true,
        tinty = true,
      },
      highlights = {
        integrations = {
          telescope = true,
          cmp       = true,
          blink     = true,
          lualine   = true,
          notify    = true,
          dapui     = true,
        },
      },
    })

    local current_scheme_file =
      vim.fn.expand("~/.local/share/tinted-theming/tinty/current_scheme")
    local f = io.open(current_scheme_file, "r")
    if f then
      local scheme = (f:read("*l") or ""):gsub("%s+$", "")
      f:close()
      if scheme ~= "" then
        pcall(vim.cmd.colorscheme, scheme)
      end
    end

    local function transparentize()
      local groups = {
        "Normal", "NormalNC", "LineNr", "Folded", "NonText", "SpecialKey",
        "VertSplit", "SignColumn", "EndOfBuffer", "StatusLineNC",
        "FoldColumn", "Pmenu",
      }
      for _, g in ipairs(groups) do
        vim.api.nvim_set_hl(0, g, { bg = "NONE" })
      end
    end
    transparentize()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = transparentize })
  end,
}
