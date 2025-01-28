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
vim.opt.termguicolors = true
vim.opt.ph = 10;
vim.cmd.colorscheme "catppuccin"

vim.filetype.add({
  extension = {
    mdx = "markdown",
    cjs = "javascript",
  }
})


local function copy_path_to_clipboard()
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
    print('No "src" directory found in path')
  end
end

-- Create the custom command
vim.api.nvim_create_user_command('CopyPathToClipboard', copy_path_to_clipboard, {})

