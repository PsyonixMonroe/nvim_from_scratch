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
                provider = 'openai_fim_compatible',
                n_completions = 1,
                context_window = 512,
                provider_options = {
                    openai_fim_compatible = {
                        api_key = "OLLAMA_KEY",
                        name = 'Ollama',
                        end_point = 'https://ollama.laserath.com/v1/completions',
                        model = 'qwen2.5-coder:7b',
                        optional = {
                            max_tokens = 56,
                            top_p = 0.9,
                        },
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
            -- minuetAction.enable_auto_trigger()
        end,
    }
}
