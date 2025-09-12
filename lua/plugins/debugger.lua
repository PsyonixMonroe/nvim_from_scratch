return {
    "mfussenegger/nvim-dap",
    dependencies = {
        'rcarriga/nvim-dap-ui',
        "nvim-neotest/nvim-nio", -- required by nvim-dap-ui
        "ldelossa/nvim-dap-projects",
        "leoluz/nvim-dap-go"
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')
        local dapprog = require('nvim-dap-projects')
        local dapgo = require('dap-go')

        dapgo.setup()

        -- setup layout
        dapui.setup({
            layouts = { {
                elements = { {
                    id = "scopes",
                    size = 0.70
                }, {
                    id = "watches",
                    size = 0.30
                } },
                position = "left",
                size = 40
            }, {
                elements = { {
                    id = "stacks",
                    size = 0.70
                }, {
                    id = "breakpoints",
                    size = 0.30
                } },
                position = "bottom",
                size = 20
            } },
        })

        -- keybinds
        vim.keymap.set('n', "<Leader>d", "", { desc = "Debugger" })
        vim.keymap.set('n', "<Leader>da", dap.clear_breakpoints, { desc = "Clear All Breakpoints" })
        vim.keymap.set('n', "<Leader>dq", dap.terminate, { desc = "Quit Session" })
        vim.keymap.set('n', "<Leader>dc", dap.continue, { desc = "Start Debugging" })
        vim.keymap.set('n', "<Leader>dr", dap.run_to_cursor, { desc = "Run to Cursor" })
        vim.keymap.set('n', "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
        vim.keymap.set({ 'n', 'x' }, "<Leader>dt", dapgo.debug_test, { desc = "Debug Test (Go)" })
        vim.keymap.set('n', "<Leader>dB", function()
            local condition = vim.fn.input("Breakpoint Conditional (optional): ")
            local hit_cond = vim.fn.input("Hit Count (optional): ")

            condition = condition ~= "" and condition or nil
            hit_cond = hit_cond ~= "" and hit_cond or nil

            dap.toggle_breakpoint(condition, hit_cond)
        end, { desc = "Toggle Conditional Breakpoint" })


        vim.keymap.set('n', "<F9>", dap.continue, { desc = "Start Debugging" })
        vim.keymap.set('n', "<F8>", dap.step_over, { desc = "Step Over" })
        vim.keymap.set('n', "<F7>", dap.step_into, { desc = "Step Into" })
        vim.keymap.set('n', "<F6>", dap.step_out, { desc = "Step Out" })

        -- Auto open/close DAP-UI
        dap.listeners.before.attach.dapui_config = function()
            require("neo-tree.command").execute({ action = "close" })
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            require("neo-tree.command").execute({ action = "close" })
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
            require("neo-tree.command").execute({ action = "show" })
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
            require("neo-tree.command").execute({ action = "show" })
        end

        local sign = vim.fn.sign_define

        -- Setup Signs and Highlights
        sign("DapBreakpoint", { text = "●", texthl = "DapBreakpointText", linehl = "DapBreakpoint", numhl = "" })
        sign("DapBreakpointCondition",
            { text = "●", texthl = "DapBreakpointCondition", linehl = "DapBreakpointCondLine", numhl = "" })
        -- sign('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })
        sign('DapStopped', { text = '', texthl = 'DapStoppedText', linehl = 'DapStopped', numhl = 'DapStopped' })

        vim.api.nvim_set_hl(0, 'DapBreakpointCondLine', { bg = '#88580b' })
        vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#ff580b' })
        vim.api.nvim_set_hl(0, 'DapBreakpointText', { fg = '#ff0000' })
        vim.api.nvim_set_hl(0, 'DapBreakpoint', { bg = '#b00000' })
        vim.api.nvim_set_hl(0, 'DapStopped', { bg = '#0B524C' })
        vim.api.nvim_set_hl(0, 'DapStoppedText', { fg = '#0B524C' })


        -- Setup Adapters
        dap.adapters.delve = function(callback, config)
            if config.mode == 'remote' and config.request == 'attach' then
                callback({
                    type = 'server',
                    host = config.host or '127.0.0.1',
                    port = config.port or '38697'
                })
            else
                callback({
                    type = 'server',
                    port = '${port}',
                    executable = {
                        command = 'dlv',
                        args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
                        detached = vim.fn.has("win32") == 0,
                    }
                })
            end
        end

        -- default configurations
        -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
        -- dap.configurations.go = {
        --     {
        --         type = "delve",
        --         name = "Debug",
        --         request = "launch",
        --         program = "${file}",
        --         outputMode = "remote",
        --     },
        --     {
        --         type = "delve",
        --         name = "Debug test", -- configuration for debugging test files
        --         request = "launch",
        --         mode = "test",
        --         program = "${file}",
        --         outputMode = "remote",
        --     },
        --     -- works with go.mod packages and sub packages
        --     {
        --         type = "delve",
        --         name = "Debug test (go.mod)",
        --         request = "launch",
        --         mode = "test",
        --         program = "./${relativeFileDirname}",
        --         outputMode = "remote",
        --     }
        -- }


        -- configurations
        dapprog.config_paths = { "./.dap_config.lua" }
        dapprog.search_project_config({ append = true })
    end,
}
