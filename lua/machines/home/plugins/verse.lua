return {
    -- "PsyonixMonroe/nvim-verse",
    dir = "~/SideProjects/Verse/nvim-verse",
    name = "nvim-verse",
    ft = { "verse" },
    dependencies = {
        "rcarriga/nvim-notify",
    },
    opts = {
        tsv_path = "~/SideProjects/Verse/tree-sitter-verse",
        lsp_config = {
            path = "verse-lsp",
            uefn_path = "/mnt/c/Users/Matt/AppData/Local/UnrealEditorFortnite",
        },
        notifications = {
            compile = true,
            push = true,
            build = false,
            log = false,
            can_push = false,
            debug = false,
        },
    },

}
