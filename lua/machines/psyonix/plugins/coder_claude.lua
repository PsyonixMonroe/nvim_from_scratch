return {
    'coder/claudecode.nvim',
    dependencies = {
        "folke/snacks.nvim",
    },
    config = true,
    opts = {
        terminal_cmd = 'claude-gateway',
    },
    keys = {
        { "<A-.>",      "<cmd>ClaudeCode<cr>",           desc = "Toggle Claude" },
        { "<Leader>t",  nil,                             desc = "AI/Claude Code" },
        { "<Leader>ts", "<cmd>ClaudeCodeSend<cr>",       mode = "v",                 desc = "Send to Claude" },
        { "<Leader>ta", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Diff Accept" },
        { "<Leader>td", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Claude Diff Deny" },
        -- { "<esc><esc><A-h>", nil, desc = "Move Left from Claude Window" },
    }
}
