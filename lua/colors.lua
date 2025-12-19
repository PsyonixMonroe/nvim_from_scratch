local function set_diff_colors()
    -- Standard diff highlights
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1a4d1a", fg = "#d0d0d0" })               -- Dark green for added lines
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#4d1a1a", fg = "#d0d0d0" })            -- Dark red for deleted lines
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#2d4f7c", fg = "#d0d0d0" })            -- Medium blue for changed lines
    vim.api.nvim_set_hl(0, "DiffText", { bg = "#5c9fd6", fg = "#ffffff", bold = true }) -- Light blue for text within change

    -- Git diff syntax highlights
    vim.api.nvim_set_hl(0, "diffAdded", { bg = "#1a4d1a", fg = "#d0d0d0" })
    vim.api.nvim_set_hl(0, "diffRemoved", { bg = "#4d1a1a", fg = "#d0d0d0" })
    vim.api.nvim_set_hl(0, "diffLine", { bg = "#3a3a5a", fg = "#d0d0d0" })

    -- Alternative names
    vim.api.nvim_set_hl(0, "Added", { bg = "#1a4d1a", fg = "#d0d0d0" })
    vim.api.nvim_set_hl(0, "Removed", { bg = "#4d1a1a", fg = "#d0d0d0" })
end

-- Set colors initially
set_diff_colors()

-- Reapply on multiple events including after diff mode is entered
local colors_group = vim.api.nvim_create_augroup("CustomDiffColors", { clear = true })
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "BufEnter", "BufWinEnter", "OptionSet" }, {
    group = colors_group,
    desc = "Apply custom diff colors",
    callback = function()
        vim.schedule(set_diff_colors)
    end,
})
