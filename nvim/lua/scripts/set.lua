vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ph = 10;
vim.opt.signcolumn = "yes"

vim.filetype.add({
  extension = {
    mdx = "markdown",
    cjs = "javascript",
  }
})


function copy_path_to_clipboard()
  -- Get the full path of the current file
  local full_path = vim.fn.expand('%:p')
  -- Find the position of 'src' in the path
  local src_position = full_path:find('src')
  if src_position then
    -- Strip everything before 'src' and copy to clipboard
    local relative_path = full_path:sub(src_position)
    vim.fn.setreg('+', relative_path)
    print('Path copied to clipboard: ' .. relative_path)
  else
    -- Copy the absolute path when no 'src' directory is found
    vim.fn.setreg('+', full_path)
    print('Absolute path copied to clipboard: ' .. full_path)
  end
end

-- Create the custom command
vim.api.nvim_create_user_command('CopyPathToClipboard', copy_path_to_clipboard, {})
