return {
    "lewis6991/gitsigns.nvim",
    opts = {
        on_attach = function(bufnr)
            local gs = require('gitsigns')
            local map = function(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end
            map('n', '<leader>gn', gs.next_hunk, { desc = "Next git hunk" })
            map('n', '<leader>gN', gs.prev_hunk, { desc = "Prev git hunk" })
        end
    }
}
