vim.keymap.set("n", "<leader>ca", vim.cmd.CodeActionMenu, { desc = 'Show code actions from LSP' })
vim.g.code_action_menu_show_details = false
vim.g.code_action_menu_show_diff = false
