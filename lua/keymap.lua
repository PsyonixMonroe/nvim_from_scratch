-- Move Commands
vim.keymap.set({ "n", "x" }, "<c-i>", "<C-u>zz", { desc = "Jump Half Page Up" })
vim.keymap.set({ "n", "x" }, "<c-u>", "<C-d>zz", { desc = "Jump Half Page Down" })
vim.keymap.set({ "n", "x" }, "n", "nzzzv", { desc = "Search Next" })
vim.keymap.set({ "n", "x" }, "N", "Nzzzv", { desc = "Search Prev" })
vim.keymap.set({ "n", "x" }, "<Esc>", "<cmd>nohlsearch<CR>")

-- Window Commands
vim.keymap.set({ "n", "x" }, "<A-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set({ "n", "x" }, "<A-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set({ "n", "x" }, "<A-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set({ "n", "x" }, "<A-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set({ "n", "x" }, "<A-\\>", ":vsplit<CR>", { desc = "Split Vertical" })
vim.keymap.set({ "n", "x" }, "<A-->", ":split<CR>", { desc = "Split Horizontal" })
vim.keymap.set({ "n", "x" }, "<c-Up>", ":resize +2<CR>", { desc = "Resize Window Vertically Up" })
vim.keymap.set({ "n", "x" }, "<c-Down>", ":resize -2<CR>", { desc = "Resize Window Vertically Down" })
vim.keymap.set({ "n", "x" }, "<c-Left>", ":vertical resize +2<CR>", { desc = "Resize Window to the Left" })
vim.keymap.set({ "n", "x" }, "<c-Right>", ":vertical resize -2<CR>", { desc = "Resize Window to the Right" })
vim.keymap.set({ "n", "x" }, "<A-]>", ":bnext<CR>", { desc = "Next tab in tabline" })
vim.keymap.set({ "n", "x" }, "<A-[>", ":bprevious<CR>", { desc = "Prev tab in tabline" })
vim.keymap.set({ "n", "x" }, "<Leader>o", ":Neotree focus<CR>", { desc = "Focus on Neotree" })
vim.keymap.set({ "n", "x" }, "<Leader>c", ":bnext<CR>:bd#<CR>", { desc = "Close Buffer" })
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
vim.keymap.set({ "n", "x" }, "<c-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move Text Up" })
vim.keymap.set({ "n", "x" }, "<c-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move Text Down" })
vim.keymap.set("v", "<", "<gv", { desc = "DeIndent Selection" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent Selection" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Text Block Up" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Text Block Down" })

-- Cut Copy Paste
vim.keymap.set({ "n", "x" }, "Y", "yy", { desc = "Yank Line" })
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
vim.keymap.set({ "n", "x" }, "<leader>le", require("telescope.builtin").lsp_references, { desc = "Goto R[e]ferences" })

-- Jump to the implementation of the word under your cursor.
--  Useful when your language has ways of declaring types without an actual implementation.
vim.keymap.set({ "n", "x" }, "<leader>li", require("telescope.builtin").lsp_implementations,
    { desc = "Goto [I]mplementation" })

-- Jump to the definition of the word under your cursor.
--  This is where a variable was first declared, or where a function is defined, etc.
--  To jump back, press <C-t>.
vim.keymap.set({ "n", "x" }, "<leader>ld", require("telescope.builtin").lsp_definitions, { desc = "Goto [D]efinition" })

-- Fuzzy find all the symbols in your current document.
--  Symbols are things like variables, functions, types, etc.
vim.keymap.set({ "n", "x" }, "<leader>ls", require("telescope.builtin").lsp_document_symbols,
    { desc = "Open Document [S]ymbols" })

-- Fuzzy find all the symbols in your current workspace.
--  Similar to document symbols, except searches over your entire project.
vim.keymap.set({ "n", "x" },
    "<leader>lw",
    require("telescope.builtin").lsp_dynamic_workspace_symbols,
    { desc = "Open [W]orkspace Symbols" }
)

-- Jump to the type of the word under your cursor.
--  Useful when you're not sure what type a variable is and you want to see
--  the definition of its *type*, not where it was *defined*.
vim.keymap.set({ "n", "x" }, "<leader>lt", require("telescope.builtin").lsp_type_definitions,
    { desc = "[G]oto [T]ype Definition" })


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
-- WARN: This is not Goto Definition, this is Goto Declaration.
--  For example, in C this would take you to the header.
vim.keymap.set({ "n", "x" }, "<leader>lD", vim.lsp.buf.declaration, { desc = "Goto [D]eclaration" })
vim.keymap.set({ "n", "x" }, "gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration of current symbol" })
vim.keymap.set({ "n", "x" }, "gd", vim.lsp.buf.definition, { desc = "[G] [D]efinition of current symbol" })
vim.keymap.set({ "n", "x" }, "gh", vim.lsp.buf.hover, { desc = "Show Line [H]over" })
vim.keymap.set({ "n", "x" }, "gi", vim.lsp.buf.implementation, { desc = "Go To [I]mplementation" })
vim.keymap.set({ "n", "x" }, "gy", vim.lsp.buf.signature_help, { desc = "Show Signature Help" })
vim.keymap.set({ "n", "x" }, "gc", vim.lsp.buf.code_action, { desc = "Perform Code Action" })
vim.keymap.set({ "n", "x" }, "<Leader>lh", vim.diagnostic.open_float, { desc = "Open Documenation" })
vim.keymap.set({ "n", "x" }, "<Leader>lg", vim.lsp.buf.hover, { desc = "Show Diagnostics" })
vim.keymap.set({ "n", "x" }, "<Leader>la", vim.lsp.buf.code_action, { desc = "Goto Code [A]ction" })
vim.keymap.set({ "n", "x" }, "<Leader>ln", function() vim.diagnostic.jump({ count = 1 }) end,
    { desc = "Go to next error" })
vim.keymap.set({ "n", "x" }, "<Leader>lN", function() vim.diagnostic.jump({ count = -1 }) end,
    { desc = "Go to prev error" })
-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
vim.keymap.set({ "n", "x" }, "<leader>lr", vim.lsp.buf.rename, { desc = "[R]ename" })
vim.keymap.set({ "n", "x" }, "<leader>sn", require("telescope").extensions.notify.notify,
    { desc = "Search Notifications" })

vim.keymap.set(
    "n",
    "<Leader>rr",
    "Oif err != nil {<CR>}<CR><Esc>kOreturn err<Esc>:lua vim.lsp.buf.format()<CR>_",
    { desc = "Go err block" }
)
vim.keymap.set({ "n", "x" }, "<Leader>rt", "", { desc = "Run Test" })





-- old plugin commands
-- vim.keymap.set("n", "<A-.>", ":ToggleTerm<CR>", { desc = "Run Terminal emulator" })
