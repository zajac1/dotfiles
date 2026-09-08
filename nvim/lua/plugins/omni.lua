-- omni theme for Neovim: `colorscheme omni`, generated from the active omni
-- theme's colors.toml by omni-nvim-theme - the same file that themes the
-- terminal, the launcher and the bar, so they always match.
--
-- This DEFERS to tinted-nvim (plugins/theme.lua) whenever tinty is managing
-- the scheme: tinted-nvim is purpose-built for base16 and has real plugin
-- integrations, while this is 60 highlight groups derived from sixteen
-- colours. On a machine without tinty - or for an omni theme generated from a
-- picture, which has no base16 equivalent - this takes over instead.
-- Priority is below theme.lua's so it loads after it.
return {
  dir = vim.fn.expand("~/.cache/omni/nvim"),
  name = "omni-theme",
  priority = 999,
  lazy = false,
  config = function()
    local tinty = vim.fn.expand("~/.local/share/tinted-theming/tinty/current_scheme")
    if vim.fn.filereadable(tinty) == 1 then
      return -- tinted-nvim owns the colours on this machine
    end
    local file = vim.fn.expand("~/.cache/omni/nvim/colors/omni.lua")
    if vim.fn.filereadable(file) == 0 then
      if vim.fn.executable("omni-nvim-theme") == 0 then return end
      vim.fn.system("omni-nvim-theme")
    end
    vim.g.omni_transparent = true -- clear backgrounds for a transparent terminal
    pcall(vim.cmd.colorscheme, "omni")
    local seen = vim.fn.getftime(file)
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        local now = vim.fn.getftime(file)
        if now ~= seen then
          seen = now
          pcall(vim.cmd.colorscheme, "omni")
        end
      end,
    })
  end,
}
