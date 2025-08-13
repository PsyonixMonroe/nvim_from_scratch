return {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                checkThirdParty = true,
                -- library = {
                --     vim.env.VIMRUNTIME
                -- }
                library = vim.api.nvim_get_runtime_file("", true)
            },
        },
    },

}
