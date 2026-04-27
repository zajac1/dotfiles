return {
  "Rigellute/shades-of-purple.vim",
  name = "Shades of Purple",
  priority = 1000,
  config = function()
    vim.cmd.colorscheme "shades_of_purple"

    local transparent_groups = {
      "Normal", "LineNr", "Folded", "NonText", "SpecialKey",
      "VertSplit", "SignColumn", "EndOfBuffer", "NormalNC",
      "StatusLineNC", "VertSplitNC", "FoldColumn", "Pmenu",
    }
    for _, group in ipairs(transparent_groups) do
      vim.api.nvim_set_hl(0, group, { bg = "NONE" })
    end
  end
}
