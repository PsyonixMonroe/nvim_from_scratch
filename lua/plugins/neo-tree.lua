-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
    "nvim-neo-tree/neo-tree.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    lazy = false,
    keys = {
        { "<Leader>e", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
    },
    opts = {
        close_if_last_window = true,
        enable_diagnostics = false,
        filesystem = {
            filtered_items = {
                hide_by_name = {
                    ".urc",
                    ".urcignore",
                },
                hide_by_pattern = {
                    "*.code-workspace",
                    "__*__",
                    "*.uasset",
                    "*.umap"
                },
                always_show = {
                    ".gitignore",
                    ".github"
                },
            },
            window = {
                mappings = {
                    ["<Leader>e"] = "close_window",
                },
                fuzzy_finder_mappings = {
                    ["<esc>"] = "noop",
                },
            },
        },
    },
}
