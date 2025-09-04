local severities = {
    error = vim.diagnostic.severity.ERROR,
    warning = vim.diagnostic.severity.WARN,
    refactor = vim.diagnostic.severity.INFO,
    convention = vim.diagnostic.severity.HINT,
}

local function get_word_at_position(line, col)
    -- Get the current buffer content as a Lua string
    local buf = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]

    -- Find the start and end positions of the word at the given column
    local start_pos = col - 1
    while start_pos >= 0 and buf:sub(start_pos + 1, start_pos + 1):match('%W') == nil do
        start_pos = start_pos - 1
    end

    local end_pos = col - 1
    while end_pos < #buf and buf:sub(end_pos + 1, end_pos + 1):match('%W') == nil do
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
            php = { "phpstan" },
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
                local decoded = vim.json.decode(output)
                if decoded['command-line-arguments'] == nil or decoded['command-line-arguments']['nilaway'] == nil then
                    return {}
                end
                local diagnostics = {}
                for _, item in ipairs(decoded['command-line-arguments']['nilaway']) do
                    local curfile = vim.api.nvim_buf_get_name(bufnr)
                    local curfile_abs = vim.fn.fnamemodify(curfile, ":p")

                    local splits = vim.fn.split(item["posn"], ":")
                    if #splits ~= 3 then
                        goto continue
                    end

                    local lintedFile = splits[1]
                    local lintedFile_abs = vim.fn.fnamemodify(lintedFile, ":p")

                    if curfile_abs == lintedFile_abs then
                        local lnum = tonumber(splits[2]) - 1
                        local col = tonumber(splits[3]) - 1

                        local word = get_word_at_position(lnum, col)
                        local offset = #word

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
