-- omni theme for Neovim: `colorscheme omni`, generated from the active omni
-- theme's colors.toml by omni-nvim-theme - the same file that themes the
-- terminal, so both always match.
--
-- Copy this into your lazy.nvim plugins directory (e.g.
-- ~/.config/nvim/lua/plugins/omni.lua) and remove any other colorscheme
-- plugin's `vim.cmd.colorscheme`. `omni-theme <name>` regenerates the file
-- and tells running Neovims to re-apply; the FocusGained hook covers the rest.
return {
  dir = vim.fn.expand("~/.cache/omni/nvim"),
  name = "omni-theme",
  priority = 1000,
  lazy = false,
  config = function()
    vim.g.omni_transparent = true   -- clear backgrounds for a transparent terminal; false for opaque
    local file = vim.fn.expand("~/.cache/omni/nvim/colors/omni.lua")
    if vim.fn.filereadable(file) == 0 then
      vim.fn.system("omni-nvim-theme")
    end
    vim.cmd.colorscheme("omni")
    local seen = vim.fn.getftime(file)
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        local now = vim.fn.getftime(file)
        if now ~= seen then
          seen = now
          vim.cmd.colorscheme("omni")
        end
      end,
    })
  end,
}
