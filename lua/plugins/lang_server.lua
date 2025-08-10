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
            }
        }
    }
}
