local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', 'gT', '<Cmd>BufferPrevious<CR>', opts)
map('n', 'gt', '<Cmd>BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', 'g<', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', 'g>', '<Cmd>BufferMoveNext<CR>', opts)
-- Goto buffer in position...
map('n', 'g1', '<Cmd>BufferGoto 1<CR>', opts)
map('n', 'g2', '<Cmd>BufferGoto 2<CR>', opts)
map('n', 'g3', '<Cmd>BufferGoto 3<CR>', opts)
map('n', 'g4', '<Cmd>BufferGoto 4<CR>', opts)
map('n', 'g5', '<Cmd>BufferGoto 5<CR>', opts)
map('n', 'g6', '<Cmd>BufferGoto 6<CR>', opts)
map('n', 'g7', '<Cmd>BufferGoto 7<CR>', opts)
map('n', 'g8', '<Cmd>BufferGoto 8<CR>', opts)
map('n', 'g9', '<Cmd>BufferGoto 9<CR>', opts)
map('n', 'g0', '<Cmd>BufferLast<CR>', opts)
-- Pin/unpin buffer
map('n', 'gp', '<Cmd>BufferPin<CR>', opts)
-- Close buffer
map('n', 'gc', '<Cmd>BufferClose<CR>', opts)
-- Magic buffer-picking mode
map('n', '<Leader>p', '<Cmd>BufferPick<CR>', opts)
-- Sort automatically by...
map('n', '<Leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
map('n', '<Leader>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
map('n', '<Leader>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
map('n', '<Leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)
