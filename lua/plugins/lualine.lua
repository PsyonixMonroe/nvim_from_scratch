local function tsstatus()
    local tstab = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    if tstab == nil then
        return [[]]
    else
        return [[TS]]
    end
end

local function location_with_total()
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    local total = vim.fn.line('$')
    return string.format('%d:%d | %d', line, col, total)
end

return {
    "nvim-lualine/lualine.nvim",
    requires = { 'nvim-tree/nvim-web-devicons', opt = true },
    opts = {
        extensions = { 'neo-tree', 'quickfix', 'mason' },
        theme = "codedark",
        options = {
            -- component_separators = { left = '', right = ''},
            component_separators = { left = '|', right = '|' },
            section_separators = { left = '', right = '' },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { 'filename', 'searchcount', },
            lualine_x = { 'encoding', 'bo:filetype', tsstatus, { 'lsp_status', icon = '', symbols = { done = '', separator = ',' } } },
            lualine_y = { 'progress' },
            lualine_z = { location_with_total },
        },
    },
}
