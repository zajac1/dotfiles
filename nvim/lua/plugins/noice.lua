return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = {
      format = {
        search_down = { icon = '' } }
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
        ["vim.lsp.buf.code_action"] = true
      },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
  }
}
