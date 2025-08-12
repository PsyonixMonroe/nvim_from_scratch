return {
    {
        "neovim/nvim-lspconfig",
        -- opts = {}
    },
    {
        "mason-org/mason.nvim",
        opts = {}
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
                "java_language_server",
                "jsonls",
                "lua_ls",
                "phpactor",
                "powershell_es",
                "sqls",
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
                end
            }
        }
    }
}
