return {
    "https://github.ol.epicgames.net/matt-monroe/nvim-verse",
    name = "nvim-verse",
    ft = { "verse" },
    dependencies = {
        "rcarriga/nvim-notify",
    },
    opts = {
        tsv_path = "C:\\Users\\MattMonroe\\AppData\\Local\\tree-sitter-verse",
        lsp_config = {
            path = "verse-lsp",
            uefn_path = "C:\\Users\\MattMonroe\\AppData\\Local\\UnrealEditorFortnite",
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
