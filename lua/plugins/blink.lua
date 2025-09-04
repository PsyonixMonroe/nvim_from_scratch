return {
    {
        "saghen/blink.cmp",
        version = '1.*',
        dependencies = {
            "L3MON4D3/LuaSnip",
        },
        opts = {
            keymap = {
                preset = 'enter',
                ["<Tab>"] = {
                    -- function(cmp)
                    --     if cmp.visible() then
                    --         return 'select_next'
                    --     end
                    -- end,
                    'snippet_forward',
                    'select_next',
                    'fallback',
                },
                ["<S-Tab>"] = {
                    'snippet_backward',
                    'select_prev',
                    'fallback',
                },
            },
            appearance = { nerd_font_variant = 'mono' },
            snippets = { preset = 'luasnip' },
            completion = {
                ghost_text = { enabled = false },
                list = {
                    selection = { preselect = false, auto_insert = true },
                },
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
                        score_offset = 10,
                    },
                    snippets = {
                        score_offset = 3,
                    },
                    path = {
                        score_offset = 2,
                    },
                    buffer = {
                        score_offset = -10,
                    },
                },
            },
            fuzzy = { implementation = 'prefer_rust' },
            signature = { enabled = true },
        },
    }
}
