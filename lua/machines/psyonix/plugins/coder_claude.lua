return {
    'coder/claudecode.nvim',
    dependencies = {
        "folke/snacks.nvim",
    },
    config = function()
        require("claudecode").setup({
            terminal_cmd = 'claude-gateway',
            diff_opts = {
                layout = "vertical",
            },
        })

        -- Wrap the _create_diff_view_from_window function to use floating windows
        vim.defer_fn(function()
            local diff = require("claudecode.diff")
            local original_create_diff = diff._create_diff_view_from_window

            diff._create_diff_view_from_window = function(target_window, old_file_path, new_buffer, tab_name, is_new_file,
                                                          terminal_win_in_new_tab, existing_buffer)
                -- Save complete window state before any changes
                local saved_windows = {}
                local original_win = nil
                for _, w in ipairs(vim.api.nvim_list_wins()) do
                    if vim.api.nvim_win_is_valid(w) then
                        local config = vim.api.nvim_win_get_config(w)
                        if config.relative == "" then -- Only save regular windows
                            if not original_win then
                                original_win = w      -- Save first valid window for restoration
                            end
                            table.insert(saved_windows, {
                                win = w,
                                buf = vim.api.nvim_win_get_buf(w),
                                width = vim.api.nvim_win_get_width(w),
                                height = vim.api.nvim_win_get_height(w),
                            })
                        end
                    end
                end

                -- Call original function to set up buffers and diff
                local result = original_create_diff(target_window, old_file_path, new_buffer, tab_name, is_new_file,
                    terminal_win_in_new_tab, existing_buffer)

                -- Schedule conversion to floating window
                vim.schedule(function()
                    -- Get the windows that were created
                    local win1 = result.target_window
                    local win2 = result.new_window

                    if not win1 or not win2 or not vim.api.nvim_win_is_valid(win1) or not vim.api.nvim_win_is_valid(win2) then
                        return
                    end

                    local buf1 = vim.api.nvim_win_get_buf(win1)
                    local buf2 = vim.api.nvim_win_get_buf(win2)

                    -- Close the diff windows FIRST before checking for restoration
                    pcall(vim.api.nvim_win_close, win1, true)
                    pcall(vim.api.nvim_win_close, win2, true)

                    -- Wait for windows to close, then restore layout and create floating windows
                    vim.schedule(function()
                        -- Check that all saved windows still exist and have correct buffers/dimensions
                        local windows_to_restore = {}
                        for _, saved in ipairs(saved_windows) do
                            if vim.api.nvim_win_is_valid(saved.win) then
                                -- Window exists, restore buffer and dimensions
                                local current_buf = vim.api.nvim_win_get_buf(saved.win)
                                if current_buf ~= saved.buf and vim.api.nvim_buf_is_valid(saved.buf) then
                                    pcall(vim.api.nvim_win_set_buf, saved.win, saved.buf)
                                end
                                -- Restore window dimensions
                                pcall(vim.api.nvim_win_set_width, saved.win, saved.width)
                                pcall(vim.api.nvim_win_set_height, saved.win, saved.height)
                            else
                                -- Window was closed, need to restore it
                                if vim.api.nvim_buf_is_valid(saved.buf) then
                                    table.insert(windows_to_restore, saved)
                                end
                            end
                        end

                        -- Recreate any closed windows
                        if #windows_to_restore > 0 then
                            -- Find a valid window to split from
                            local base_win = nil
                            for _, w in ipairs(vim.api.nvim_list_wins()) do
                                local config = vim.api.nvim_win_get_config(w)
                                if config.relative == "" then
                                    base_win = w
                                    break
                                end
                            end

                            if base_win then
                                for _, saved in ipairs(windows_to_restore) do
                                    vim.api.nvim_set_current_win(base_win)
                                    vim.cmd("vsplit")
                                    local new_win = vim.api.nvim_get_current_win()
                                    pcall(vim.api.nvim_win_set_buf, new_win, saved.buf)
                                    pcall(vim.api.nvim_win_set_width, new_win, saved.width)
                                    pcall(vim.api.nvim_win_set_height, new_win, saved.height)
                                end
                            end
                        end

                        -- Force restore all window dimensions one more time after everything settles
                        vim.schedule(function()
                            for _, saved in ipairs(saved_windows) do
                                if vim.api.nvim_win_is_valid(saved.win) then
                                    pcall(vim.api.nvim_win_set_width, saved.win, saved.width)
                                    pcall(vim.api.nvim_win_set_height, saved.win, saved.height)
                                end
                            end
                        end)

                        -- Now create the floating diff windows after layout is restored
                        -- Calculate dimensions for side-by-side floating windows
                        local total_width = math.floor(vim.o.columns * 0.9)
                        local diff_height = math.floor(vim.o.lines * 0.85) - 2 -- Reserve space for header
                        local col_start = math.floor((vim.o.columns - total_width) / 2)

                        -- Calculate relative file path for display
                        local display_path = old_file_path
                        if display_path then
                            display_path = vim.fn.fnamemodify(display_path, ':.')
                        else
                            display_path = "[New File]"
                        end

                        -- Create header buffer with centered filename
                        local header_buf = vim.api.nvim_create_buf(false, true)
                        local header_width = total_width + 2 -- Account for center gap
                        local padding = math.floor((header_width - #display_path) / 2)
                        local centered_text = string.rep(" ", math.max(0, padding)) .. display_path
                        vim.api.nvim_buf_set_lines(header_buf, 0, -1, false, { centered_text })
                        vim.api.nvim_buf_set_option(header_buf, 'modifiable', false)
                        vim.api.nvim_buf_set_option(header_buf, 'bufhidden', 'wipe')

                        -- Create header window
                        local header_row = math.floor((vim.o.lines - diff_height - 3) / 2)
                        local float_win_header = vim.api.nvim_open_win(header_buf, false, {
                            relative = 'editor',
                            row = header_row,
                            col = col_start,
                            width = header_width,
                            height = 1,
                            style = 'minimal',
                            border = 'rounded',
                        })
                        vim.wo[float_win_header].cursorline = false

                        -- Position diff windows below header
                        local diff_row = header_row + 3 -- Header height + border

                        -- Divide width exactly in half for equal sizing
                        local half_width = math.floor(total_width / 2)
                        -- Add gap between windows for visual separation (2 columns for border spacing)
                        local center_gap = 2

                        -- Create first window (left side - original)
                        local float_win_left = vim.api.nvim_open_win(buf1, false, {
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
                        vim.wo[float_win_left].diff = true

                        -- Create second window (right side - proposed) with center gap
                        local float_win_right = vim.api.nvim_open_win(buf2, true, {
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
                        vim.wo[float_win_right].diff = true

                        -- Sync diff scroll positions and jump to first change
                        vim.schedule(function()
                            -- Set scrollbind on both windows without changing focus
                            vim.wo[float_win_left].scrollbind = true
                            vim.wo[float_win_left].cursorbind = true
                            vim.wo[float_win_right].scrollbind = true
                            vim.wo[float_win_right].cursorbind = true

                            -- Jump to first diff change in the proposed window
                            vim.api.nvim_set_current_win(float_win_right)
                            vim.cmd("diffupdate")
                            -- Go to top first, then find first change
                            vim.cmd("normal! gg")
                            -- Use pcall since ]c fails if no diffs exist
                            pcall(vim.cmd, "normal! ]c")

                            -- Initial sync of scroll positions
                            vim.cmd("syncbind")
                        end)

                        -- Set focus to the proposed (right) window
                        vim.api.nvim_set_current_win(float_win_right)

                        -- Update result to reflect new windows
                        result.new_window = float_win_right
                        result.target_window = float_win_left

                        -- Add mouse scroll synchronization since scrollbind doesn't handle mouse
                        local scroll_group = vim.api.nvim_create_augroup(
                            "ClaudeCodeFloatingDiffScroll_" .. tostring(float_win_right), { clear = true })

                        local syncing = false -- Prevent infinite loop
                        vim.api.nvim_create_autocmd("WinScrolled", {
                            group = scroll_group,
                            callback = function(args)
                                if syncing then return end

                                local scrolled_win = tonumber(args.match)
                                if not scrolled_win then return end

                                -- Check if one of our diff windows scrolled
                                if scrolled_win == float_win_left or scrolled_win == float_win_right then
                                    local other_win = (scrolled_win == float_win_left) and float_win_right or float_win_left

                                    if not vim.api.nvim_win_is_valid(scrolled_win) or not vim.api.nvim_win_is_valid(other_win) then
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

                        -- Helper function to close floating windows and restore focus
                        local function cleanup_floating_windows()
                            -- Close our diff floating windows and header
                            if vim.api.nvim_win_is_valid(float_win_header) then
                                pcall(vim.api.nvim_win_close, float_win_header, true)
                            end
                            if vim.api.nvim_win_is_valid(float_win_left) then
                                pcall(vim.api.nvim_win_close, float_win_left, true)
                            end
                            if vim.api.nvim_win_is_valid(float_win_right) then
                                pcall(vim.api.nvim_win_close, float_win_right, true)
                            end

                            -- Close any other floating windows that might have been left behind
                            vim.schedule(function()
                                for _, win in ipairs(vim.api.nvim_list_wins()) do
                                    if vim.api.nvim_win_is_valid(win) then
                                        local config = vim.api.nvim_win_get_config(win)
                                        if config.relative ~= "" then
                                            pcall(vim.api.nvim_win_close, win, true)
                                        end
                                    end
                                end

                                -- Restore original window dimensions
                                for _, saved in ipairs(saved_windows) do
                                    if vim.api.nvim_win_is_valid(saved.win) then
                                        pcall(vim.api.nvim_win_set_width, saved.win, saved.width)
                                        pcall(vim.api.nvim_win_set_height, saved.win, saved.height)
                                    end
                                end

                                -- Return to original window (but avoid terminal windows)
                                if original_win and vim.api.nvim_win_is_valid(original_win) then
                                    local buf = vim.api.nvim_win_get_buf(original_win)
                                    if vim.api.nvim_buf_is_valid(buf) then
                                        local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
                                        -- Only restore focus if it's not a terminal
                                        if buftype ~= 'terminal' then
                                            pcall(vim.api.nvim_set_current_win, original_win)
                                        else
                                            -- Find a non-terminal window to focus
                                            for _, saved in ipairs(saved_windows) do
                                                if vim.api.nvim_win_is_valid(saved.win) then
                                                    local saved_buf = vim.api.nvim_win_get_buf(saved.win)
                                                    local saved_buftype = vim.api.nvim_buf_get_option(saved_buf, 'buftype')
                                                    if saved_buftype ~= 'terminal' then
                                                        pcall(vim.api.nvim_set_current_win, saved.win)
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end

                                -- Force comprehensive redraw to fix rendering issues
                                vim.schedule(function()
                                    vim.cmd("redraw!")
                                end)
                            end)
                        end

                        -- Clean up floating windows when the proposed buffer is deleted (accept/deny)
                        local cleanup_group = vim.api.nvim_create_augroup(
                            "ClaudeCodeFloatingDiffCleanup_" .. tostring(float_win_right), { clear = true })

                        vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
                            group = cleanup_group,
                            buffer = buf2,
                            callback = cleanup_floating_windows,
                            once = true,
                        })

                        -- Also clean up if either floating window is closed directly
                        vim.api.nvim_create_autocmd("WinClosed", {
                            group = cleanup_group,
                            pattern = { tostring(float_win_left), tostring(float_win_right) },
                            callback = cleanup_floating_windows,
                            once = true,
                        })
                    end) -- end inner vim.schedule
                end)     -- end outer vim.schedule

                return result
            end
        end, 100)
    end,
    opts = {
        terminal_cmd = 'claude-gateway',
    },
    keys = {
        { "<A-.>",      "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude" },
        { "<Leader>t",  nil,                             desc = "AI/Claude Code" },
        { "<Leader>ts", "<cmd>ClaudeCodeSend<cr>",       mode = "v",                 desc = "Send to Claude" },
        { "<Leader>ta", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Diff Accept" },
        { "<Leader>td", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude Diff Deny" },
        -- { "<esc><esc><A-h>", nil, desc = "Move Left from Claude Window" },
    }
}
