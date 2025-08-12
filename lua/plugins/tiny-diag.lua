return {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000,    -- needs to be loaded in first
    config = function()
        require("tiny-inline-diagnostic").setup({
            preset = "powerline",
            options = {
                show_source = {
                    enabled = true,
                    if_many = false,
                },
                multilines = {
                    always_show = false,
                    enabled = true,
                },
                show_all_diags_on_cursorline = true,
            },
            blend = {
                factor = 0.22,
            },
        })
        vim.diagnostic.config(
            {
                underline = true,
                virtual_text = false,
                update_in_insert = true,
                severity_sort = true,
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = " ",
                        [vim.diagnostic.severity.WARN] = " ",
                        [vim.diagnostic.severity.HINT] = " ",
                        [vim.diagnostic.severity.INFO] = " ",
                    }
                }
            }
        )
    end,
}
