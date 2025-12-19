return {
    'greggh/claude-code.nvim',
    requires = {
        'nvim-lua/plenary.nvim', -- Required for git operations
    },
    enabled = false,
    config = function()
        require("claude-code").setup({
            window = {
                position = "vertical",
            },
            command = 'claude-gateway',
            keymaps = {
                toggle = {
                    normal = "<A-.>",
                    terminal = "<A-.>",
                    variants = {
                        continue = "<A-a>___",
                        verbose = "<A-a>__",
                    },
                },
                window_navigation = false,
                scrolling = false,
            },
        })
        vim.keymap.set(
            't',
            '<A-h>',
            [[<C-\><C-n><C-w>h:lua require("claude-code").force_insert_mode()<CR>]],
            { noremap = true, silent = true, desc = 'Window: move left' }
        )
    end
}
