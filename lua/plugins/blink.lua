return {
    {
        "saghen/blink.cmp",
        version = '1.*',
        opts = {
            keymap = { preset = 'super-tab' },
            appearance = { nerd_font_variant = 'mono' },
            completion = {
                ghost_text = { enabled = true },
                documentation = { auto_show = true },
                menu = {
                    draw = {
                        columns = {
                            { "label",       'label_description', gap = 1 },
                            { "kind_icon",   "kind",              gap = 1 },
                            { "source_name", gap = 1 },
                        }
                    }
                },
            },
            sources = {
                default = { 'Lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    Lsp = {
                        name = 'Lsp',
                        module = 'blink.cmp.sources.lsp',
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                return item.kind ~= require('blink.cmp.types').CompletionItemKind.Keyword
                            end, items)
                        end,
                    },
                },
            },
            fuzzy = { implementation = 'prefer_rust' },
            signature = { enabled = true },
        },
    }
}
