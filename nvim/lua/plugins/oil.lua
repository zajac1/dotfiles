return {
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = true,
    },
    git = {
      -- Return true to automatically git add/mv/rm files
      add = function()
        return true
      end,
      mv = function()
        return true
      end,
      rm = function()
        return true
      end,
    },
  },
  lazy = false,
}
