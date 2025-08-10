return {
    {
        "echasnovski/mini.ai",
        version = "*",
        lazy = false,
        opts = {},
    },
    {
        "echasnovski/mini.surround",
        version = "*",
        lazy = false,
        opts = {
            search_method = "cover_or_next",
        },
    },
    {
        "echasnovski/mini.trailspace",
        version = "*",
        lazy = false,
        opts = {},
    },
    {
        "echasnovski/mini.indentscope",
        version = "*",
        lazy = false,
        config = function()
            require("mini.indentscope").setup({
                draw = {
                    delay = 50,
                    animation = require("mini.indentscope").gen_animation.none(),
                },
            })
        end,
    },
}
