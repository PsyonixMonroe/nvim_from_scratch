---@type LazySpec
return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        config = true,
        lazy = false,
        keys = {
            {
                "<Leader>h",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = "Harpoon Menu",
            },
            {
                "<Leader>a",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():add()
                end,
                desc = "Add to Harpoon list",
            },
            {
                "<Leader>r",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():clear()
                end,
                desc = "Reset Harpoon list",
            },
            {
                "<A-1>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(1)
                end,
                desc = "Jump to Harpoon 1",
            },
            {
                "<A-2>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(2)
                end,
                desc = "Jump to Harpoon 2",
            },
            {
                "<A-3>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(3)
                end,
                desc = "Jump to Harpoon 3",
            },
            {
                "<A-4>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(4)
                end,
                desc = "Jump to Harpoon 4",
            },
            {
                "<A-q>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(5)
                end,
                desc = "Jump to Harpoon 5",
            },
            {
                "<A-w>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(6)
                end,
                desc = "Jump to Harpoon 6",
            },
            {
                "<A-e>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():select(7)
                end,
                desc = "Jump to Harpoon 7",
            },
            {
                "<A-r>",
                function()
                    local harpoon = require("harpoon")
                    harpoon:list():remove()
                end,
                desc = "remove buffer from harpoon",
            },
        },
    },
}
