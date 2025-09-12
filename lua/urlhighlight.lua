-- [[URL Highlighting]]
local highlighturl_group = vim.api.nvim_create_augroup("highlighturl", { clear = true })
vim.api.nvim_set_hl(0, "HighlightURL", { default = true, underline = true })
vim.api.nvim_create_autocmd("ColorScheme", {
    group = highlighturl_group,
    desc = "Set up HighlightURL hlgroup",
    callback = function()
        vim.api.nvim_set_hl(0, "HighlightURL", { default = true, underline = true })
    end,
})
vim.api.nvim_create_autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
    group = highlighturl_group,
    desc = "Highlight URLs",
    callback = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            Set_url_match(win)
        end
    end,
})

local url_matcher =
"\\v\\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\\-=?!+/0-9a-z]+|:\\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\\([&:#*@~%_\\-=?!+;/.0-9a-z]*\\)|\\[[&:#*@~%_\\-=?!+;/.0-9a-z]*\\]|\\{%([&:#*@~%_\\-=?!+;/.0-9a-z]*|\\{[&:#*@~%_\\-=?!+;/.0-9a-z]*})\\})+"

--- Delete the syntax matching rules for URLs/URIs if set
---@param win? integer the window id to remove url highlighting in (default: current window)
function Delete_url_match(win)
    if not win then
        win = vim.api.nvim_get_current_win()
    end
    for _, match in ipairs(vim.fn.getmatches(win)) do
        if match.group == "HighlightURL" then
            vim.fn.matchdelete(match.id, win)
        end
    end
    vim.w[win].highlighturl_enabled = false
end

function Set_url_match(win)
    if not win then
        win = vim.api.nvim_get_current_win()
    end
    Delete_url_match(win)
    vim.fn.matchadd("HighlightURL", url_matcher, 15, -1, { window = win })
    vim.w[win].highlighturl_enabled = true
end
