require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map('n', '<leader>gs', gs.stage_hunk, {desc = 'Stage the current Git hunk' })
    map('n', '<leader>gr', gs.reset_hunk, {desc = 'Reset (unstage) the current Git hunk' })
    map('n', '<leader>gu', gs.undo_stage_hunk, {desc = 'Undo the last Git hunk staging' })
    map('n', '<leader>gp', gs.preview_hunk, {desc = 'Preview the changes in the current Git hunk' })
    map('n', '<leader>gb', function() gs.blame_line{full=true} end, {desc = 'Show Git blame information for the current line' })
    map('n', '<leader>gd', gs.toggle_deleted, {desc = 'Toggle between showing deleted hunks and regular view'})

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}
