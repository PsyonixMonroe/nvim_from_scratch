return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- Guard against servers sending nil registrations (jdtls)
            local orig = vim.lsp.handlers["client/registerCapability"]
            vim.lsp.handlers["client/registerCapability"] = function(err, params, ctx)
                if not params or not params.registrations then
                    return vim.NIL
                end
                return orig(err, params, ctx)
            end
        end,
    },
    {
        "mason-org/mason.nvim",
        opts = {
            ensure_installed = {
                "selene",
                "golangci-lint",
                "nilaway",
                "checkstyle",
                "google-java-format",
            }
        }
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "bashls",
                "clangd",
                "csharp_ls",
                "cssls",
                "dockerls",
                "eslint",
                "gopls",
                "helm_ls",
                "html",
                "jdtls",
                "jsonls",
                "lua_ls",
                "phpactor",
                "powershell_es",
                "terraformls",
                "tflint",
                "ts_ls",
                "yamlls",
                "zls",
            },
            automatic_installation = true,
            handlers = {
                function(server_name)
                    local capabilities = require("blink.cmp").get_lsp_capabilities()
                    local server = {}
                    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
                    require("lspconfig")[server_name].setup(server)
                    vim.diagnostic.config({ virtual_text = false, })
                end,
                ["java_language_server"] = function() end,
            }
        }
    }
}
