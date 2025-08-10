return {
    { "blazkowolf/gruber-darker.nvim", lazy = false },
    { "ray-x/aurora",                  lazy = false },
    { "ribru17/bamboo.nvim",           lazy = false },
    { "xero/miasma.nvim",              lazy = false },
    { "cocopon/iceberg.vim",           lazy = false },
    { "p00f/nvim-ts-rainbow",          lazy = false }, -- Colorize matching brackets
    { "folke/tokyonight.nvim",         lazy = false },
    { "vague2k/vague.nvim",            lazy = false },
    {
        "AstroNvim/astrotheme",
        priority = 1000, -- Make sure to load this before all the other start plugins.
        opts = {},
        lazy = false,
    },
    {
        "ntk148v/habamax.nvim",
        dependencies = { "rktjmp/lush.nvim" },
        lazy = false,
    },
}
