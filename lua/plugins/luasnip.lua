return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    run = "make install_jsregexp",
    config = function()
        local ls = require "luasnip"
        ls.setup({
        })
        local types = require "luasnip.util.types"

        ls.config.set_config {
            history = true,

            updateEvents = "TextChanged,TextChangedI",

            enable_autosnippets = true,
        }

        vim.keymap.set({ "i", "s" }, "<A-n>", function()
            if ls.expand_or_jumpable() then
                ls.expand_or_jump()
            end
        end, { silent = true, desc = "Snippet Expand or Next" })

        vim.keymap.set({ "i", "s" }, "<A-N>", function()
            if ls.jumpable(-1) then
                ls.jump(-1)
            end
        end, { silent = true, desc = "Snippet Previous" })

        vim.keymap.set({ "i", "s" }, "<A-u>", function()
            if ls.choice_active() then
                ls.change_choice(1)
            end
        end, { desc = "Snippet Change Choice" })

        vim.keymap.set("n", "<leader><leader>s", "<CMD>source ~/.config/nvim/after/plugin/luasnip.lua<CR>",
            { desc = "Reload LuaSnip Config" })
    end
}
