local telescope = require('telescope')
local builtin = require('telescope.builtin')
local previewers = require('telescope.previewers')

local delta = previewers.new_termopen_previewer({
  get_command = function(entry)
    if entry.status == '??' or 'A ' then
      return { 'git', 'diff', entry.value }
    end

    return { 'git', 'diff', entry.value .. '^!' }
  end
})

telescope.setup({
  defaults = {
    prompt_prefix = "  󰭎  ",
    selection_caret = " ❯ ",
    entry_prefix = "   ",
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
})
telescope.load_extension("recent_files")
telescope.load_extension('fzf')
telescope.load_extension('ui-select')

vim.keymap.set('n', '<leader>p', builtin.git_files, { desc = 'Omnisearch for all *git* files' })
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = 'Grep through *all* files' })
vim.keymap.set('n', '<leader>s', function() builtin.git_status({ previewer = delta, layout_strategy = 'vertical' }) end,
  { desc = 'List of files according to git status' })
vim.keymap.set('n', '<leader>r', telescope.extensions.recent_files.pick, { desc = 'List of recent files' })
vim.keymap.set("n", "<leader>h", builtin.keymaps, { desc = 'Show Telescope menu for all available keybindings' })
