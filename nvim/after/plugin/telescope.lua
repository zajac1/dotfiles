local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.load_extension("recent_files")
telescope.setup({
    defaults = {
        prompt_prefix = "  󰭎  ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
    },
})

vim.keymap.set('n', '<leader>p', builtin.git_files, { desc = 'Omnisearch for all *git* files' })
vim.keymap.set('n', '<leader>f', builtin.live_grep, { desc = 'Grep through *all* files' })
vim.keymap.set('n', '<leader>g', builtin.git_status, { desc = 'List of files according to git status' })
vim.api.nvim_set_keymap('n', '<leader>r',
    [[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
    { desc = 'List of recent files' })
