vim.g.mapleader = " "

vim.api.nvim_set_keymap('n', '<leader><CR>', ':Oil --float<CR>', { desc = 'Toggle Oil filetree' })
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Paste before in visual mode' })
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = 'Toggle Undotree' })
vim.keymap.set("n", "J", "mzJ`z", { desc = 'Join lines in normal mode' })
vim.keymap.set("n", "]]", "<C-d>", { desc = 'Move down half screen' })
vim.keymap.set("n", "[[", "<C-u>", { desc = 'Move up half screen' })
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = 'Search and replace' })
vim.keymap.set("n", "<leader>w", "<C-w>", { desc = 'Pane navigation' })
vim.keymap.set("n", "<leader>gg", vim.cmd.LazyGit, { desc = 'Show LazyGit panel' })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Preview symbol definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, { desc = 'Show signature help' })
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Show warnings & errors for current buffer' })
vim.keymap.set('n', '<F2>', vim.lsp.buf.rename)
vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, { desc = 'Show code actions menu' })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = 'Copy to system cliboard in normal and visual mode' })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = 'Delete without copying content to buffer' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down in visual mode' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up in visual mode' })
vim.keymap.set('n', '<leader>e', function() vim.cmd('LspEslintFixAll') end, { desc = 'Apply ESLint fix all' })

-- Terminal mappings
vim.keymap.set('n', '<leader>te', function()
    vim.cmd('terminal')
    vim.cmd('startinsert')
end, { desc = 'Open terminal in new buffer' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode to normal mode' })

-- Copy path to clipboard shortcut
vim.keymap.set('n', '<D-S-C>', copy_path_to_clipboard, { desc = 'Copy path to clipboard' })

-- Terminal configuration
vim.api.nvim_create_autocmd('TermOpen', {
    callback = function()
        -- Disable line numbers in terminal buffers
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = 'no'

        -- Add C-c mapping to close terminal buffer in normal mode
        vim.keymap.set('n', '<C-c>', ':bdelete!<CR>', { desc = 'Close terminal buffer', buffer = 0 })
    end
})
local function open_cursor_agent_float()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Cursor Agent ",
    title_pos = "center",
  })

  vim.cmd('terminal cursor-agent')
  vim.cmd('startinsert')
end

vim.keymap.set('n', '<leader>ca', open_cursor_agent_float, 
  { desc = 'Open cursor-agent in floating window' })

