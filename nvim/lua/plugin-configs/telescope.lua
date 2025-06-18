local telescope = require('telescope')
local builtin = require('telescope.builtin')
local previewers = require('telescope.previewers')
local telescopeConfig = require("telescope.config")

local delta = previewers.new_termopen_previewer({
  get_command = function(entry)
    if entry.status == '??' or 'A ' then
      return { 'git', 'diff', entry.value }
    end

    return { 'git', 'diff', entry.value .. '^!' }
  end
})

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
table.insert(vimgrep_arguments, "--fixed-strings")

telescope.setup({
  defaults = {
    prompt_prefix = "  󰭎  ",
    selection_caret = " ❯ ",
    entry_prefix = "   ",
    vimgrep_arguments = vimgrep_arguments,
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
vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'Show references (Telescope)' })
vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'Go to definition' })
vim.keymap.set('n', 'go', builtin.lsp_type_definitions, { desc = 'Go to type definition' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Go to implementation' })
