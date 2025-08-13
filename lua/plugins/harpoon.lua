---@type LazySpec
return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        config = function()
            Harpoon = require("harpoon")
        end,
        lazy = false,
        keys = {
            {
                "<Leader>h",
                function()
                    Harpoon.ui:toggle_quick_menu(Harpoon:list())
                end,
                desc = "Harpoon Menu",
            },
            {
                "<Leader>a",
                function()
                    Harpoon:list():add()
                end,
                desc = "Add to Harpoon list",
            },
            {
                "<Leader>r",
                function()
                    Harpoon:list():clear()
                end,
                desc = "Reset Harpoon list",
            },
            {
                "<A-1>",
                function()
                    Harpoon:list():select(1)
                end,
                desc = "Jump to Harpoon 1",
            },
            {
                "<A-2>",
                function()
                    Harpoon:list():select(2)
                end,
                desc = "Jump to Harpoon 2",
            },
            {
                "<A-3>",
                function()
                    Harpoon:list():select(3)
                end,
                desc = "Jump to Harpoon 3",
            },
            {
                "<A-4>",
                function()
                    Harpoon:list():select(4)
                end,
                desc = "Jump to Harpoon 4",
            },
            {
                "<A-q>",
                function()
                    Harpoon:list():select(5)
                end,
                desc = "Jump to Harpoon 5",
            },
            {
                "<A-w>",
                function()
                    Harpoon:list():select(6)
                end,
                desc = "Jump to Harpoon 6",
            },
            {
                "<A-e>",
                function()
                    Harpoon:list():select(7)
                end,
                desc = "Jump to Harpoon 7",
            },
            {
                "<A-r>",
                function()
                    Harpoon:list():remove()
                end,
                desc = "remove buffer from harpoon",
            },
        },
    },
}
