return {
    "mfussenegger/nvim-dap",
    dependencies = {
        'rcarriga/nvim-dap-ui',
        "nvim-neotest/nvim-nio", -- required by nvim-dap-ui
    },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')
        dapui.setup({
            -- disable repl and console
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

        vim.keymap.set('n', "<Leader>d", "", { desc = "Debugger" })
        vim.keymap.set('n', "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
        vim.keymap.set('n', "<Leader>da", dap.clear_breakpoints, { desc = "Clear All Breakpoints" })
        vim.keymap.set('n', "<Leader>dq", dap.terminate, { desc = "Quit Session" })
        vim.keymap.set('n', "<Leader>dc", dap.continue, { desc = "Start Debugging" })


        vim.keymap.set('n', "<F9>", dap.continue, { desc = "Start Debugging" })
        vim.keymap.set('n', "<F8>", dap.step_over, { desc = "Step Over" })
        vim.keymap.set('n', "<F7>", dap.step_into, { desc = "Step Into" })
        vim.keymap.set('n', "<F6>", dap.step_out, { desc = "Step Out" })

        vim.keymap.set({ 'v', 'n' }, "<Leader>dr", dapui.eval, { desc = "Run Selected Text" })

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

        -- Setup for Go
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


        -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
        dap.configurations.go = {
            {
                type = "delve",
                name = "Debug",
                request = "launch",
                program = "${file}"
            },
            {
                type = "delve",
                name = "Debug test", -- configuration for debugging test files
                request = "launch",
                mode = "test",
                program = "${file}"
            },
            -- works with go.mod packages and sub packages
            {
                type = "delve",
                name = "Debug test (go.mod)",
                request = "launch",
                mode = "test",
                program = "./${relativeFileDirname}"
            }
        }
    end,
}
