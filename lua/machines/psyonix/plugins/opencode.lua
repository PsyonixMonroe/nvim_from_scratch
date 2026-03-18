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
                local terminal_pid = nil
                local terminal_buf = nil

                ---@type snacks.terminal.Opts
                local terminal_opts = {
                    win = {
                        position = "right",
                        enter = true,
                        width = math.floor(vim.o.columns * 0.4),
                        on_win = function(win)
                            local buf = vim.api.nvim_win_get_buf(win.win)
                            terminal_buf = buf
                            require("opencode.terminal").setup(win.win)
                            vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], {
                                buffer = buf,
                                noremap = true,
                                silent = true,
                                desc = "Window: move left",
                            })
                        end,
                    },
                }

                --- Cache the terminal PID from the buffer's job.
                --- Must be called after jobstart (not in on_win, which fires before).
                local function cache_terminal_pid()
                    if terminal_pid then return end
                    if not terminal_buf then return end
                    local job_id = vim.b[terminal_buf]
                        and vim.b[terminal_buf].terminal_job_id
                    if not job_id then return end
                    local ok, pid = pcall(vim.fn.jobpid, job_id)
                    if ok and pid then terminal_pid = pid end
                end

                local function terminate_opencode()
                    if not terminal_pid then return end
                    -- Negative PID terminates entire process group
                    os.execute("kill -TERM -" .. terminal_pid .. " 2>/dev/null")
                    terminal_pid = nil
                end

                vim.api.nvim_create_autocmd("ExitPre", {
                    once = true,
                    callback = terminate_opencode,
                })

                --- Find the listening port for a PID or its descendants.
                ---@param pid integer
                ---@return number|nil
                local function find_listening_port(pid)
                    -- Collect this PID + all descendants
                    local pids = { tostring(pid) }
                    local pgrep = vim.system(
                        { "pgrep", "-P", tostring(pid) }, { text = true }):wait()
                    if pgrep.code == 0 and pgrep.stdout then
                        for _, p in ipairs(vim.split(pgrep.stdout, "\n", { trimempty = true })) do
                            table.insert(pids, p)
                            -- One more level deep for shell -> bun -> opencode
                            local pgrep2 = vim.system(
                                { "pgrep", "-P", p }, { text = true }):wait()
                            if pgrep2.code == 0 and pgrep2.stdout then
                                for _, p2 in ipairs(vim.split(pgrep2.stdout, "\n", { trimempty = true })) do
                                    table.insert(pids, p2)
                                end
                            end
                        end
                    end
                    local lsof = vim.system({
                        "lsof", "-Fpn", "-w", "-iTCP", "-sTCP:LISTEN",
                        "-p", table.concat(pids, ","), "-a", "-P", "-n",
                    }, { text = true }):wait()
                    if lsof.code == 0 and lsof.stdout then
                        for line in lsof.stdout:gmatch("[^\n]+") do
                            if line:sub(1, 1) == "n" then
                                local port = tonumber(line:match(":(%d+)$"))
                                if port then return port end
                            end
                        end
                    end
                    return nil
                end

                local function connect_to_server()
                    if require("opencode.events").connected_server then return end
                    local function try_connect()
                        if require("opencode.events").connected_server then return end
                        cache_terminal_pid()
                        if not terminal_pid then return end
                        local port = find_listening_port(terminal_pid)
                        if not port then return end
                        -- Build server object and connect to SSE events
                        require("opencode.cli.client").get_path(port, function(path)
                            local cwd = path.directory or path.worktree
                            if not cwd then return end
                            require("opencode.cli.client").get_agents(port, function(agents)
                                local subagents = vim.tbl_filter(
                                    function(a) return a.mode == "subagent" end, agents)
                                require("opencode.cli.client").get_sessions(port, function(sessions)
                                    local title = sessions[1] and sessions[1].title
                                        or "<No sessions>"
                                    require("opencode.cli.client").get_commands(port, function(cmds)
                                        if require("opencode.events").connected_server then
                                            return
                                        end
                                        require("opencode.events").connect({
                                            port = port,
                                            cwd = cwd,
                                            title = title,
                                            subagents = subagents,
                                            custom_commands = cmds,
                                        })
                                    end)
                                end)
                            end)
                        end, function() end)
                    end
                    vim.defer_fn(try_connect, 2000)
                    vim.defer_fn(try_connect, 5000)
                end
                return {
                    start = function()
                        require("snacks.terminal").open(cmd, terminal_opts)
                        connect_to_server()
                    end,
                    stop = function()
                        terminate_opencode()
                        require("snacks.terminal").get(cmd, terminal_opts):close()
                    end,
                    toggle = function()
                        require("snacks.terminal").toggle(cmd, terminal_opts)
                        connect_to_server()
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

        --- Apply a unified diff to source lines, returning the patched result.
        --- Parses hunks from the diff text and applies insertions/deletions.
        ---@param orig_lines string[]
        ---@param diff_text string
        ---@return string[]|nil patched_lines
        local function apply_unified_diff(orig_lines, diff_text)
            local diff_lines = vim.split(diff_text, '\n')
            local result = {}
            local orig_idx = 1

            local i = 1
            -- Skip header lines (---, +++, diff, index, etc.) until first hunk
            while i <= #diff_lines do
                if diff_lines[i]:match('^@@') then break end
                i = i + 1
            end

            while i <= #diff_lines do
                local line = diff_lines[i]
                local hunk_header = line:match('^@@%s+%-(%d+)')
                if not hunk_header then
                    i = i + 1
                    goto continue
                end

                local hunk_start = tonumber(hunk_header)
                -- Copy unchanged lines before this hunk
                while orig_idx < hunk_start do
                    table.insert(result, orig_lines[orig_idx])
                    orig_idx = orig_idx + 1
                end

                i = i + 1
                while i <= #diff_lines do
                    line = diff_lines[i]
                    if line:match('^@@') or line:match('^diff ') then break end
                    local prefix = line:sub(1, 1)
                    local content = line:sub(2)
                    if prefix == '-' then
                        -- Skip removed line from original
                        orig_idx = orig_idx + 1
                    elseif prefix == '+' then
                        -- Add new line
                        table.insert(result, content)
                    elseif prefix == ' ' then
                        -- Context line
                        table.insert(result, content)
                        orig_idx = orig_idx + 1
                    elseif line == '\\ No newline at end of file' then
                        -- skip
                    else
                        -- Unknown prefix, treat as context
                        table.insert(result, line)
                        orig_idx = orig_idx + 1
                    end
                    i = i + 1
                end
                ::continue::
            end

            -- Copy remaining original lines after last hunk
            while orig_idx <= #orig_lines do
                table.insert(result, orig_lines[orig_idx])
                orig_idx = orig_idx + 1
            end

            return result
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

            -- Apply unified diff in pure Lua (avoids external `patch` command issues)
            local proposed_lines = apply_unified_diff(orig_lines, diff_text)

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
                    -- Delay until user is idle to avoid issues with terminal focus
                    require("opencode.util").on_user_idle(500, function()
                        create_floating_diff(event, port)
                    end)
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
