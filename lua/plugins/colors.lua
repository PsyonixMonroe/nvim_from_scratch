return {
    { "vague2k/vague.nvim", lazy = false },
    {
        "AstroNvim/astrotheme",
        priority = 1000, -- Make sure to load this before all the other start plugins.
        opts = {},
        lazy = false,
    },
    {
        "hiphish/rainbow-delimiters.nvim",
        lazy = false,
    }
    -- { "blazkowolf/gruber-darker.nvim", lazy = false },
    -- { "ray-x/aurora",                  lazy = false },
    -- { "ribru17/bamboo.nvim",           lazy = false },
    -- { "xero/miasma.nvim",              lazy = false },
    -- { "cocopon/iceberg.vim",           lazy = false },
    -- { "folke/tokyonight.nvim",         lazy = false },
    -- {
    --      "ntk148v/habamax.nvim",
    --      dependencies = { "rktjmp/lush.nvim" },
    --      lazy = false,
    -- },
}
