return {
    {
        "saghen/blink.cmp",
        version = '1.*',
        opts = {
            keymap = { preset = 'enter' },
            appearance = { nerd_font_variant = 'mono' },
            completion = {
                documentation = { auto_show = true },
                menu = {
                    draw = {
                        columns = {
                            { "label",      'label_description', gap = 1 },
                            { "kind_icon",  "kind" },
                            { "source_name" },
                        }
                    }
                },
            },
            sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
            fuzzy = { implementation = 'prefer_rust' },
        },
    }
}
