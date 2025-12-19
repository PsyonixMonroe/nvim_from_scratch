return {
    { -- Autoformat
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>lf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = "",
                desc = "[F]ormat buffer",
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = function(bufnr)
                -- Disable "format_on_save lsp_fallback" for languages that don't
                -- have a well standardized coding style. You can add additional
                -- languages here or re-enable it for the disabled ones.
                local disable_filetypes = { c = true, cpp = true, csharp = true }
                if disable_filetypes[vim.bo[bufnr].filetype] or vim.b.autoformat == false then
                    return nil
                else
                    return {
                        timeout_ms = 500,
                        lsp_format = "fallback",
                    }
                end
            end,
            formatters_by_ft = {
                -- lua = { "stylua" },
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use 'stop_after_first' to run the first available formatter from the list
                javascript = { "prettierd", "prettier", "eslint", stop_after_first = true },
                typescript = { "prettierd", "prettier", "eslint", stop_after_first = true },
            },
        },
    },
    {
        'windwp/nvim-ts-autotag',
        opts = {
            opts = {
                enable_close_on_slash = false -- Auto close on trailing </
            },
            per_filetype = {
                ["html"] = {
                    enable_close = false
                }
            }
        }
    }
}
