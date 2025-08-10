local map = function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { desc = "LSP: " .. desc })
end

-- Move Commands
vim.keymap.set("n", "<c-i>", "<C-u>zz", { desc = "Jump Half Page Up" })
vim.keymap.set("n", "<c-u>", "<C-d>zz", { desc = "Jump Half Page Down" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Search Next" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Search Prev" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Window Commands
vim.keymap.set("n", "<A-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<A-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<A-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<A-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<A-\\>", ":vsplit<CR>", { desc = "Split Vertical" })
vim.keymap.set("n", "<A-->", ":split<CR>", { desc = "Split Horizontal" })
vim.keymap.set("n", "<c-Up>", ":resize +2<CR>", { desc = "Resize Window Vertically Up" })
vim.keymap.set("n", "<c-Down>", ":resize -2<CR>", { desc = "Resize Window Vertically Down" })
vim.keymap.set("n", "<c-Left>", ":vertical resize +2<CR>", { desc = "Resize Window to the Left" })
vim.keymap.set("n", "<c-Right>", ":vertical resize -2<CR>", { desc = "Resize Window to the Right" })
vim.keymap.set("n", "<A-]>", ":bnext<CR>", { desc = "Next tab in tabline" })
vim.keymap.set("n", "<A-[>", ":bprevious<CR>", { desc = "Prev tab in tabline" })
vim.keymap.set("n", "<Leader>o", ":Neotree focus<CR>", { desc = "Focus on Neotree" })
vim.keymap.set("n", "<Leader>c", ":bnext<CR>:bd#<CR>", { desc = "Close Buffer" })
-- never really used these harpoon ones, but wanted the tabline ones back
-- ["<A-]>"] = {
--     function()
--         local harpoon = require "harpoon"
--         harpoon:list():next()
--     end,
--     desc = "Next Harpoon",
-- },
-- ["<A-[>"] = {
--     function()
--         local harpoon = require "harpoon"
--         harpoon:list():prev()
--     end,
--     desc = "Prev Harpoon",
-- },

-- Text Move
vim.keymap.set("n", "<c-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move Text Up" })
vim.keymap.set("n", "<c-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move Text Down" })
vim.keymap.set("v", "<", "<gv", { desc = "DeIndent Selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Selection" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Text Block Up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Text Block Down" })

-- Cut Copy Paste
vim.keymap.set("n", "Y", "yy", { desc = "Yank Line" })
vim.keymap.set("v", "p", '"_dP', { desc = "Paste" })
vim.keymap.set("v", "<c-x>", '"+x', { desc = "Cut" })
vim.keymap.set("v", "<c-c>", '"+y', { desc = "Copy" })
vim.keymap.set("v", "<c-v>", '"_d"+gP', { desc = "Paste" })
vim.keymap.set("v", "<Leader>y", '"+y', { desc = "Yank to Clipboard" })
vim.keymap.set("v", "<Leader>p", '"+gP', { desc = "Paste and keep Clipboard" })
vim.keymap.set("x", "<c-x>", '"+x', { desc = "Cut" })
vim.keymap.set("x", "<c-c>", '"+y', { desc = "Copy" })
vim.keymap.set("x", "<c-v>", '"_d"+gP', { desc = "Paste" })
vim.keymap.set("x", "<Leader>y", '"+y', { desc = "Yank to Clipboard" })
vim.keymap.set("x", "<Leader>p", '"+gP', { desc = "Paste and keep Clipboard" })
vim.keymap.set("i", "<c-v>", '<ESC>"+gPa', { desc = "Paste" })

-- Diff Commands
vim.keymap.set("n", "<Leader>r<Leader>", ":diffget 1<CR>", { desc = "Take Left Diff" })
vim.keymap.set("n", "<Leader>g<Leader>", ":diffget 2<CR>", { desc = "Take Center Diff" })
vim.keymap.set("n", "<Leader>u<Leader>", ":diffget 3<CR>", { desc = "Take Right Diff" })

-- Lua
vim.keymap.set("n", "<Leader>x", "<cmd>:.lua<CR>", { desc = "Execute Line (lua)" })
vim.keymap.set("n", "<Leader><Leader>x", "<cmd>source %<CR>", { desc = "Load File (lua)" })
vim.keymap.set("v", "<Leader>x", "<cmd>:lua<CR>", { desc = "Execute Selection (lua)" })

-- Telescope
vim.keymap.set("n", "<Leader>fa", "<cmd>Telescope find_files<CR>", { desc = "Find All Files" })
vim.keymap.set("n", "<Leader>ff", "<cmd>Telescope git_files<CR>", { desc = "Find Git Files" })
vim.keymap.set("n", "<Leader>fd", function()
    require("telescope.builtin").lsp_document_symbols({ search = vim.fn.input("Grep > ") })
end, { desc = "Grep for string in files" })
vim.keymap.set("n", "<Leader>fs", function()
    require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Grep for string in files" })

-- Find references for the word under your cursor.
map("<leader>le", require("telescope.builtin").lsp_references, "Goto R[e]ferences")

-- Jump to the implementation of the word under your cursor.
--  Useful when your language has ways of declaring types without an actual implementation.
map("<leader>li", require("telescope.builtin").lsp_implementations, "Goto [I]mplementation")

-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
map("<leader>ld", require("telescope.builtin").lsp_definitions, "Goto [D]efinition")

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
map("<leader>ls", require("telescope.builtin").lsp_document_symbols, "Open Document [S]ymbols")

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
map(
    "<leader>lw",
    require("telescope.builtin").lsp_dynamic_workspace_symbols,
    "Open [W]orkspace Symbols"
)

-- Jump to the type of the word under your cursor.
--  Useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.
map("<leader>lt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")


-- Quick Fix
vim.keymap.set("n", "<Leader>qn", ":cnext<CR>", { desc = "Quick Fix Next" })
vim.keymap.set("n", "<Leader>qb", ":cprev<CR>", { desc = "Quick Fix Previous" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- File Commands
vim.keymap.set("n", "<Leader>us", ":autocmd! save_all_buffers<CR>", { desc = "toggle autosave" })
vim.keymap.set("n", "<A-s>", ":w<CR>", { desc = "Save File" })

-- Misc
vim.keymap.set("n", "<Leader>bv", "<C-v>", { desc = "Enter visual block mode" })
vim.keymap.set(
    "n",
    "<Leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Search and Replace Word Under Cursor" }
)

-- LSP
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration of current symbol" })
vim.keymap.set("n", "gd", vim.lsp.buf.declaration, { desc = "Declaration of current symbol" })
vim.keymap.set("n", "gh", vim.lsp.buf.hover, { desc = "Show Line Hover" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go To Implementation" })
vim.keymap.set("n", "gy", vim.lsp.buf.signature_help, { desc = "Show Signature Help" })
vim.keymap.set("n", "gc", vim.lsp.buf.code_action, { desc = "Perform Code Action" })
vim.keymap.set("n", "<leader>lh", vim.diagnostic.open_float, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>ln", function() vim.diagnostic.jump({count=1}) end, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>lN", function() vim.diagnostic.jump({count=-1}) end, { desc = "Go to prev error" })
vim.keymap.set("n", "<leader>lg", vim.lsp.buf.hover, { desc = "Show Documentation" })
vim.keymap.set("n", "<leader>rt", "", { desc = "Run Test" })

vim.keymap.set("n", "<Leader>lc", ":GoCmt<CR>", { desc = "Add stub GoDoc" })
vim.keymap.set(
    "n",
    "<Leader>rr",
    "Oif err != nil {<CR>}<CR><Esc>kOreturn err<Esc>:lua vim.lsp.buf.format()<CR>_",
    { desc = "Go err block" }
)


-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
map("<leader>lr", vim.lsp.buf.rename, "[R]ename")

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
map("<leader>la", vim.lsp.buf.code_action, "Goto Code [A]ction", { "n", "x" })

-- WARN: This is not Goto Definition, this is Goto Declaration.
--  For example, in C this would take you to the header.
map("<leader>lD", vim.lsp.buf.declaration, "Goto [D]eclaration")

-- old plugin commands
-- vim.keymap.set("n", "<A-.>", ":ToggleTerm<CR>", { desc = "Run Terminal emulator" })

