local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    desc = "highlight text on yank",
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    desc = "Open files to last location",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    desc = "resize splits when vim resizes",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    desc = "Make Directories when saving files",
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    -- group = vim.api.nvim_create_augroup("remove_crlf", { clear = true }),
    group = augroup,
    desc = "Remove Windows Style Line endings",
    callback = function()
        -- print(vim.bo.buftype)
        vim.cmd(' \
            if !&readonly && !(&buftype == "nofile") && !(&buftype == "terminal") && !(&buftype == "quickfix") && !(&filetype == "harpoon") && !(&buftype == "prompt") && !isdirectory(expand("%") && (!vim.fn.expand("%") == "")) \
                :%s/\r//ge \
            endif \
        ')
    end,
})

vim.api.nvim_create_autocmd({ "FocusLost", "BufWinLeave" }, {
    pattern = { "*" },
    group = augroup,
    desc = "Save buffer when leaving the buffer",
    callback = function()
        vim.cmd(' \
            if !&readonly && !(&buftype == "nofile") && !(&buftype == "terminal") && !(&filetype == "harpoon") && !(&buftype == "quickfix") && !(&buftype == "prompt") && !isdirectory(expand("%") && (!vim.fn.expand("%") == "")) && filereadable(bufname("%")) \
                :w! \
            endif \
        ')
    end,
})
