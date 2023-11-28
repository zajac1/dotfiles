function ColorMyPencils(color)
    vim.cmd.colorscheme(color)

    vim.cmd('highlight Normal guibg=none ctermbg=none')
    vim.cmd('highlight LineNr guibg=none ctermbg=none')
    vim.cmd('highlight Folded guibg=none ctermbg=none')
    vim.cmd('highlight NonText guibg=none ctermbg=none')
    vim.cmd('highlight SpecialKey guibg=none ctermbg=none')
    vim.cmd('highlight VertSplit guibg=none ctermbg=none')
    vim.cmd('highlight SignColumn guibg=none ctermbg=none')
    vim.cmd('highlight EndOfBuffer guibg=none ctermbg=none')
    vim.cmd('highlight NormalNC guibg=none ctermbg=none')  
    vim.cmd('highlight StatusLineNC guibg=none ctermbg=none') 
    vim.cmd('highlight VertSplitNC guibg=none ctermbg=none') 
    vim.cmd('highlight FoldColumn guibg=none ctermbg=none') 
    vim.cmd('highlight Pmenu guibg=none ctermbg=none')

end

ColorMyPencils()
