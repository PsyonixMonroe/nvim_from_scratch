local function tsstatus()
    local tstab = vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
    if tstab == nil then
        return [[]]
    else
        return [[TS]]
    end
end

return {
    "nvim-lualine/lualine.nvim",
    requires = {'nvim-tree/nvim-web-devicons', opt = true},
    opts = {
        extensions = { 'neo-tree', 'quickfix', 'mason' },
        theme = "codedark",
        options = {
            -- component_separators = { left = '', right = ''},
            component_separators = { left = '|', right = '|'},
            section_separators = { left = '', right = ''},
        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'branch', 'diff', 'diagnostics'},
            lualine_c = {'filename', 'searchcount' },
            lualine_x = {'encoding', 'bo:filetype', tsstatus, {'lsp_status', icon='', symbols={ done='', separator=',' }}},
            lualine_y = {'progress'},
            lualine_z = {'location'},
        },
    },
}
