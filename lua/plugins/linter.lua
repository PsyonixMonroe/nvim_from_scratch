local severities = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    refactor = vim.diagnostic.severity.INFO,
    convention = vim.diagnostic.severity.HINT,
}

local function get_word_at_position(bufnr, line, col)
    -- Get the buffer content as a Lua string
    local lines = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)
    if #lines == 0 then
        return ""
    end
    local buf = lines[1]

    -- Find the start and end positions of the word at the given column
    local start_pos = col
    while start_pos > 0 and buf:sub(start_pos, start_pos):match('%W') == nil do
        start_pos = start_pos - 1
    end

    local end_pos = col
    while end_pos <= #buf and buf:sub(end_pos + 1, end_pos + 1):match('%W') == nil do
        end_pos = end_pos + 1
    end

    -- Extract the word using Lua string manipulation
    local word = buf:sub(start_pos + 1, end_pos)
    return word
end

return {
    "mfussenegger/nvim-lint",
    event = {
        "BufReadPre",
        "BufNewFile",
    },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            terraform = { "tflint" },
            go = { "golangcilint", "nilaway" },
            lua = { "selene" },
            json = { "jsonlint" },
            -- php = { "phpstan" },
        }

        lint.linters.nilaway = {
            name = "nilaway",
            cmd = "nilaway",
            stdin = false,
            append_fname = true,
            args = { "-json", "-pretty-print=false" },
            stream = "stdout",
            parser = function(output, bufnr)
                if output == '' then
                    return {}
                end

                -- Safely decode JSON
                local ok, decoded = pcall(vim.json.decode, output)
                if not ok then
                    vim.notify("nilaway: failed to parse JSON output", vim.log.levels.DEBUG)
                    return {}
                end

                if type(decoded) ~= 'table' or
                   decoded['command-line-arguments'] == nil or
                   decoded['command-line-arguments']['nilaway'] == nil then
                    return {}
                end

                local diagnostics = {}
                for _, item in ipairs(decoded['command-line-arguments']['nilaway']) do
                    -- Safely handle item parsing
                    if type(item) ~= 'table' or not item["posn"] or not item["message"] then
                        goto continue
                    end

                    local curfile = vim.api.nvim_buf_get_name(bufnr)
                    local curfile_abs = vim.fn.fnamemodify(curfile, ":p")

                    local splits = vim.fn.split(item["posn"], ":")
                    if #splits ~= 3 then
                        goto continue
                    end

                    local lintedFile = splits[1]
                    local lintedFile_abs = vim.fn.fnamemodify(lintedFile, ":p")

                    if curfile_abs == lintedFile_abs then
                        local lnum = tonumber(splits[2])
                        local col = tonumber(splits[3])

                        -- Validate line and column numbers
                        if not lnum or not col or lnum < 1 or col < 1 then
                            goto continue
                        end

                        lnum = lnum - 1
                        col = col - 1

                        -- Verify buffer is valid and line exists
                        if not vim.api.nvim_buf_is_valid(bufnr) then
                            goto continue
                        end

                        local line_count = vim.api.nvim_buf_line_count(bufnr)
                        if lnum >= line_count then
                            goto continue
                        end

                        local ok_word, word = pcall(get_word_at_position, bufnr, lnum, col)
                        local offset = ok_word and #word or 1

                        table.insert(diagnostics, {
                            lnum = lnum,
                            col = col,
                            end_lnum = lnum,
                            end_col = col + offset - 1,
                            severity = vim.diagnostic.severity.ERROR,
                            source = "nilaway",
                            message = item.message,
                        })
                    end

                    ::continue::
                end

                return diagnostics
            end,
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>ll", lint.try_lint, { desc = "Trigger Linting" })
    end,
}
