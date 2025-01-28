vim.g.mapleader = " "

vim.api.nvim_set_keymap('n', '<leader><CR>', ':Oil --float<CR>', { desc = 'Toggle Oil filetree' })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = 'Toggle Undotree' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down in visual mode' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up in visual mode' })
vim.keymap.set("n", "J", "mzJ`z", { desc = 'Join lines in normal mode' })
vim.keymap.set("n", "]]", "<C-d>", { desc = 'Move down half screen' })
vim.keymap.set("n", "[[", "<C-u>", { desc = 'Move up half screen' })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Paste before in visual mode' })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = 'Copy to system cliboard in normal and visual mode' })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = 'Delete without copying content to buffer' })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Search and replace' })
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = 'Pane navigation' })
vim.keymap.set("n", "<leader>gg", vim.cmd.LazyGit, { desc = 'Show LazyGit panel' })
vim.keymap.set("n", "<leader>=", vim.cmd.EslintFixAll, { desc = 'Fix everything in file using eslint' })
vim.keymap.set("n", "<leader>-", vim.cmd.Prettier, { desc = 'Fix everything in file using prettier' })
