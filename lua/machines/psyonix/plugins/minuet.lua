return {
    {
        "milanglacier/minuet-ai.nvim",
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
        },
        config = function()
            require('minuet').setup({
                virtual_text = {
                    auto_trigger_ft = { '*' },
                    show_on_completion_menu = true,
                },
                provider = 'claude',
                n_completions = 1,
                context_window = 512,
                provider_options = {
                    claude = {
                        max_tokens = 512,
                        model = 'claude-3-5-haiku-latest',
                        stream = true,
                        api_key = 'ANTHROPIC_API_KEY',
                        end_point = 'https://api.portkey.ai/v1/messages',
                    },
                },
            })
            local minuetAction = require("minuet.virtualtext").action
            vim.keymap.set({ "i" }, '<A-u>', minuetAction.accept, { desc = "Accept LLM Virtualtext" })
            vim.keymap.set({ "i" }, '<A-i>', minuetAction.accept_line, { desc = "Accept Line of LLM Virtualtext" })
            vim.keymap.set({ "i" }, '<A-o>', minuetAction.accept_n_lines, { desc = "Accept n lines of LLM Virtualtext" })
            vim.keymap.set({ "i" }, '<A-[>', minuetAction.prev, { desc = "Goto Prev LLM Virtualtext" })
            vim.keymap.set({ "i" }, '<A-]>', minuetAction.next, { desc = "Goto Next LLM Virtualtext" })
            vim.keymap.set({ "i" }, '<A-p>', minuetAction.dismiss, { desc = "Dismiss LLM Virtualtext" })

            vim.keymap.set({ "n" }, '<A-a>t', minuetAction.toggle_auto_trigger, { desc = "Toggle AI Virtualtext" })
            minuetAction.enable_auto_trigger()

            -- local augroup = vim.api.nvim_create_augroup("UserMinuet", {})
            -- vim.api.nvim_create_autocmd({ "User" }, {
            --     pattern = "MinuetRequestStarted",
            --     group = augroup,
            --     desc = "Log Starting Request",
            --     callback = function()
            --         vim.notify("Minuet Started")
            --     end,
            -- })
            -- vim.api.nvim_create_autocmd({ "User" }, {
            --     pattern = "MinuetRequestStarted",
            --     group = augroup,
            --     desc = "Log Finished Request",
            --     callback = function(args)
            --         vim.notify("Minuet Finished " .. args.data.name .. " : " .. args.data.model)
            --     end,
            -- })
        end,
    }
}
