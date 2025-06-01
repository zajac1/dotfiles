vim.keymap.set('n', 'gT', vim.cmd.BufferPrevious, { desc = 'Go to previous tab' })
vim.keymap.set('n', 'gt', vim.cmd.BufferNext, { desc = 'Go to next tab' })
vim.keymap.set('n', 'g<', vim.cmd.BufferMovePrevious, { desc = 'Reorder tab to previous' })
vim.keymap.set('n', 'g>', vim.cmd.BufferMoveNext, { desc = 'Reorder tab to next' })
vim.keymap.set('n', 'gp', vim.cmd.BufferPin, { desc = 'Pin tab' })
vim.keymap.set('n', 'gx', vim.cmd.BufferClose, { desc = 'Close tab' })
vim.keymap.set('n', 'gX', vim.cmd.BufferCloseAllButCurrentOrPinned,
  { desc = 'Close all tabs except pinned and current one' })
vim.keymap.set('n', 'g;', vim.cmd.BufferPick, { desc = 'Tab-picking mode' })
for i = 1, 9 do
  vim.keymap.set('n', 'g' .. i, function() vim.cmd.BufferGoto(i) end, { desc = 'Go to tab number ' .. i })
end
vim.keymap.set('n', 'g0', vim.cmd.BufferLast, { desc = 'Go to the last tab' })
