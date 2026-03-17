return {
    'NickvanDyke/opencode.nvim',
    enabled = true,
    dependencies = { 'folke/snacks.nvim', opts = { input = {}, picker = {}, terminal = {} } },
    config = function()
        vim.g.opencode_opts = {
            events = {
                permissions = {
                    enabled = true,
                    edits = {
                        enabled = false, -- Replaced by floating diff below
                    },
                },
            },
            server = (function()
                local cmd = "opencode --port"
                ---@type snacks.terminal.Opts
                local terminal_opts = {
                    win = {
                        position = "right",
                        enter = true,
                        width = math.floor(vim.o.columns * 0.4),
                        on_win = function(win)
                            require("opencode.terminal").setup(win.win)
                            local buf = vim.api.nvim_win_get_buf(win.win)
                            vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], {
                                buffer = buf,
                                noremap = true,
                                silent = true,
                                desc = "Window: move left",
                            })
                        end,
                    },
                }
                return {
                    start = function()
                        require("snacks.terminal").open(cmd, terminal_opts)
                    end,
                    stop = function()
                        require("snacks.terminal").get(cmd, terminal_opts):close()
                    end,
                    toggle = function()
                        require("snacks.terminal").toggle(cmd, terminal_opts)
                    end,
                }
            end)()
        }
        vim.o.autoread = true

        -- Floating diff view for opencode edit permissions
        local current_edit_request_id = nil
        local float_state = nil

        local function cleanup_floating_diff()
            if not float_state then return end
            local state = float_state
            float_state = nil
            current_edit_request_id = nil

            for _, win in ipairs({ state.header_win, state.left_win, state.right_win }) do
                if win and vim.api.nvim_win_is_valid(win) then
                    pcall(vim.api.nvim_win_close, win, true)
                end
            end

            if state.augroup then
                pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
            end

            vim.schedule(function()
                for _, saved in ipairs(state.saved_windows or {}) do
                    if vim.api.nvim_win_is_valid(saved.win) then
                        pcall(vim.api.nvim_win_set_width, saved.win, saved.width)
                        pcall(vim.api.nvim_win_set_height, saved.win, saved.height)
                    end
                end

                -- Focus the opencode terminal window
                local found_terminal = false
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_is_valid(win) then
                        local buf = vim.api.nvim_win_get_buf(win)
                        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' then
                            pcall(vim.api.nvim_set_current_win, win)
                            vim.cmd("startinsert")
                            found_terminal = true
                            break
                        end
                    end
                end
                if not found_terminal and state.original_win and vim.api.nvim_win_is_valid(state.original_win) then
                    pcall(vim.api.nvim_set_current_win, state.original_win)
                end

                vim.schedule(function() vim.cmd("redraw!") end)
            end)
        end

        local function create_floating_diff(event, port)
            -- Clean up any previous diff
            if float_state then cleanup_floating_diff() end

            local diff_text = event.properties.metadata.diff
            local filepath = event.properties.metadata.filepath
            current_edit_request_id = event.properties.id

            -- Save window state for restoration
            local saved_windows = {}
            local original_win = nil
            for _, w in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_is_valid(w) then
                    local config = vim.api.nvim_win_get_config(w)
                    if config.relative == "" then
                        if not original_win then original_win = w end
                        table.insert(saved_windows, {
                            win = w,
                            buf = vim.api.nvim_win_get_buf(w),
                            width = vim.api.nvim_win_get_width(w),
                            height = vim.api.nvim_win_get_height(w),
                        })
                    end
                end
            end

            -- Read original file (empty for new files)
            local orig_lines = {}
            if vim.fn.filereadable(filepath) == 1 then
                orig_lines = vim.fn.readfile(filepath)
            end

            -- Apply patch to produce proposed content
            local orig_tmp = vim.fn.tempname()
            local patch_tmp = vim.fn.tempname() .. '.patch'
            local patched_tmp = vim.fn.tempname()
            vim.fn.writefile(orig_lines, orig_tmp)
            vim.fn.writefile(vim.split(diff_text, '\n'), patch_tmp)
            vim.fn.system(string.format('patch --quiet -o %s %s %s 2>/dev/null',
                vim.fn.shellescape(patched_tmp),
                vim.fn.shellescape(orig_tmp),
                vim.fn.shellescape(patch_tmp)))
            local proposed_lines = vim.fn.readfile(patched_tmp)
            vim.fn.delete(orig_tmp)
            vim.fn.delete(patch_tmp)
            vim.fn.delete(patched_tmp)

            if not proposed_lines or #proposed_lines == 0 then
                vim.notify("Failed to apply patch for floating diff", vim.log.levels.ERROR, { title = "opencode" })
                return
            end

            -- Detect filetype for syntax highlighting
            local ft = vim.filetype.match({ filename = filepath })

            -- Create original (left) buffer
            local buf_orig = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf_orig, 0, -1, false, orig_lines)
            if ft then vim.bo[buf_orig].filetype = ft end
            vim.bo[buf_orig].modifiable = false
            vim.bo[buf_orig].bufhidden = 'wipe'

            -- Create proposed (right) buffer
            local buf_proposed = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf_proposed, 0, -1, false, proposed_lines)
            if ft then vim.bo[buf_proposed].filetype = ft end
            vim.bo[buf_proposed].bufhidden = 'wipe'

            -- Floating window dimensions
            local total_width = math.floor(vim.o.columns * 0.9)
            local diff_height = math.floor(vim.o.lines * 0.85) - 2
            local col_start = math.floor((vim.o.columns - total_width) / 2)
            local half_width = math.floor(total_width / 2)
            local center_gap = 2

            -- Header with centered filename
            local display_path = vim.fn.fnamemodify(filepath, ':.')
            local header_buf = vim.api.nvim_create_buf(false, true)
            local header_width = total_width + center_gap
            local padding = math.floor((header_width - #display_path) / 2)
            vim.api.nvim_buf_set_lines(header_buf, 0, -1, false,
                { string.rep(" ", math.max(0, padding)) .. display_path })
            vim.bo[header_buf].modifiable = false
            vim.bo[header_buf].bufhidden = 'wipe'

            local header_row = math.floor((vim.o.lines - diff_height - 3) / 2)
            local diff_row = header_row + 3

            local header_win = vim.api.nvim_open_win(header_buf, false, {
                relative = 'editor',
                row = header_row,
                col = col_start,
                width = header_width,
                height = 1,
                style = 'minimal',
                border = 'rounded',
            })
            vim.wo[header_win].cursorline = false

            -- Left window (original)
            local left_win = vim.api.nvim_open_win(buf_orig, false, {
                relative = 'editor',
                row = diff_row,
                col = col_start,
                width = half_width,
                height = diff_height,
                style = 'minimal',
                border = 'rounded',
                title = ' Original ',
                title_pos = 'center',
            })
            vim.wo[left_win].diff = true

            -- Right window (proposed)
            local right_win = vim.api.nvim_open_win(buf_proposed, true, {
                relative = 'editor',
                row = diff_row,
                col = col_start + half_width + center_gap,
                width = half_width,
                height = diff_height,
                style = 'minimal',
                border = 'rounded',
                title = ' Proposed ',
                title_pos = 'center',
            })
            vim.wo[right_win].diff = true

            -- Track state for cleanup
            local augroup = vim.api.nvim_create_augroup(
                "OpencodeFloatingDiffCleanup_" .. tostring(right_win), { clear = true })

            float_state = {
                header_win = header_win,
                left_win = left_win,
                right_win = right_win,
                buf_proposed = buf_proposed,
                saved_windows = saved_windows,
                original_win = original_win,
                augroup = augroup,
            }

            -- Sync scroll positions and jump to first change
            vim.schedule(function()
                vim.wo[left_win].scrollbind = true
                vim.wo[left_win].cursorbind = true
                vim.wo[right_win].scrollbind = true
                vim.wo[right_win].cursorbind = true

                vim.api.nvim_set_current_win(right_win)
                vim.cmd("diffupdate")
                vim.cmd("normal! gg")
                pcall(vim.cmd, "normal! ]c")
                vim.cmd("syncbind")
            end)

            -- Keymaps for accept/reject on both buffers
            local function set_diff_keymaps(buf)
                local function bmap(key, action, desc, opts)
                    opts = vim.tbl_extend('force', { buffer = buf, desc = desc }, opts or {})
                    vim.keymap.set('n', key, action, opts)
                end

                bmap('<leader>ta', function()
                    require("opencode.cli.client").permit(port, event.properties.id, "once")
                    cleanup_floating_diff()
                end, "Accept opencode edit")

                bmap('<leader>tr', function()
                    require("opencode.cli.client").permit(port, event.properties.id, "reject")
                    cleanup_floating_diff()
                end, "Reject opencode edit")

                bmap('q', cleanup_floating_diff, "Close diff")
                bmap('<Esc>', cleanup_floating_diff, "Close diff")
            end

            set_diff_keymaps(buf_orig)
            set_diff_keymaps(buf_proposed)

            -- Mouse scroll synchronization (scrollbind doesn't handle mouse)
            local syncing = false
            vim.api.nvim_create_autocmd("WinScrolled", {
                group = augroup,
                callback = function(scroll_args)
                    if syncing then return end
                    local scrolled_win = tonumber(scroll_args.match)
                    if not scrolled_win then return end

                    if scrolled_win == left_win or scrolled_win == right_win then
                        local other_win = (scrolled_win == left_win) and right_win or left_win
                        if not vim.api.nvim_win_is_valid(scrolled_win)
                            or not vim.api.nvim_win_is_valid(other_win) then
                            return
                        end
                        syncing = true
                        pcall(function()
                            local view = vim.api.nvim_win_call(scrolled_win, vim.fn.winsaveview)
                            vim.api.nvim_win_call(other_win, function()
                                vim.fn.winrestview(view)
                            end)
                        end)
                        syncing = false
                    end
                end,
            })

            -- Clean up if either diff window is closed directly
            vim.api.nvim_create_autocmd("WinClosed", {
                group = augroup,
                pattern = { tostring(left_win), tostring(right_win) },
                callback = cleanup_floating_diff,
                once = true,
            })
        end

        vim.api.nvim_create_autocmd("User", {
            group = vim.api.nvim_create_augroup("OpencodeFloatingDiff", { clear = true }),
            pattern = { "OpencodeEvent:permission.asked", "OpencodeEvent:permission.replied" },
            callback = function(args)
                local event = args.data.event
                local port = args.data.port

                if event.type == "permission.asked" and event.properties.permission == "edit" then
                    create_floating_diff(event, port)
                elseif event.type == "permission.replied"
                    and current_edit_request_id
                    and event.properties.requestID == current_edit_request_id then
                    -- Edit accepted/rejected from the TUI; close our floating diff
                    cleanup_floating_diff()
                end
            end,
            desc = "Floating diff view for opencode edits",
        })
    end,
    -- stylua: ignore
    keys = {
        { '<A-.>',      function() require('opencode').toggle() end,                           desc = 'Toggle embedded opencode', },
        { '<leader>oa', function() require('opencode').ask() end,                              desc = 'Ask opencode',                 mode = 'n', },
        { '<leader>oa', function() require('opencode').ask('@selection: ') end,                desc = 'Ask opencode about selection', mode = 'v', },
        { '<leader>op', function() require('opencode').select_prompt() end,                    desc = 'Select prompt',                mode = { 'n', 'v', }, },
        { '<leader>on', function() require('opencode').command('session_new') end,             desc = 'New session', },
        { '<leader>oy', function() require('opencode').command('messages_copy') end,           desc = 'Copy last message', },
        { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end,   desc = 'Scroll messages up', },
        { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'Scroll messages down', },
    },
}
