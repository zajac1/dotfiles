local lsp = require('lsp-zero')
local cmp = require('cmp')
local cmp_action = lsp.cmp_action()

local sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»',
}

local icons = {
    Array = "",
    Boolean = "",
    Class = "",
    Color = "",
    Constant = "",
    Constructor = "",
    Enum = "",
    EnumMember = "",
    Event = "",
    Field = "",
    File = "",
    Folder = "󰉋",
    Function = "",
    Interface = "",
    Key = "",
    Keyword = "",
    Method = "",
    Module = "",
    Namespace = "",
    Null = "󰟢",
    Number = "",
    Object = "",
    Operator = "",
    Package = "",
    Property = "",
    Reference = "",
    Snippet = "",
    String = "",
    Struct = "",
    Text = "",
    TypeParameter = "",
    Unit = "",
    Value = "",
    Variable = "",
}

lsp.preset('recommended')
lsp.ensure_installed({
    'tsserver',
})

vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', { desc = 'Preview symbol definition' })
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', { desc = 'Go to declaration' })
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', { desc = 'Go to implementation' })
vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', { desc = 'Go to type definition' })
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', { desc = 'Show references' })
vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', { desc = 'Show signature help' })
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>',
    { desc = 'Show warnings & errors for current buffer' })

lsp.set_sign_icons(sign_icons)
lsp.setup_nvim_cmp({
    mapping =
    {
        ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
        ['<C-Space>'] = cmp.mapping.complete(),
    },
    formatting =
    {
        fields = { "kind", "abbr", "menu" },
        kind_icons = icons,
        format = function(entry, vim_item)
            vim_item.kind = icons[vim_item.kind]
            return vim_item
        end,

    }
})
local lua_opts = lsp.nvim_lua_ls()

require('lspconfig').lua_ls.setup(lua_opts)
lsp.setup()

