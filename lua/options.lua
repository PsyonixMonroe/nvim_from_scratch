-- Left column
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

-- command
vim.o.timeoutlen = 300

-- utils
vim.o.mouse = "a"
vim.o.mousemoveevent = true

-- files
vim.o.swapfile = false
vim.o.undofile = true
vim.o.confirm = true

-- long lines
vim.o.breakindent = true
vim.o.showbreak = "> "
vim.o.wrap = false

-- Search
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.inccommand = "split"

-- splits
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- clipboard
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- cursor
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.sidescrolloff = 10
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true

-- visuals
vim.o.winborder = "rounded"
vim.o.showmode = false

vim.g.markdown_fenced_languages = {
    "html",
    "python",
    "vim",
    "sql",
    "mysql",
    "php",
    "go",
    "godoc",
    "bash",
    "cs",
    "c",
    "cpp",
    "cmake",
    "valgrind",
    "rust",
    "git",
    "sql",
    "mysql",
    "zig",
    "config",
    "confini",
    "gdb",
    "java",
    "javacc",
    "javascript",
    "json",
    "make",
    "nginx",
    "nix",
    "sed",
    "sh",
    "sshconfig",
    "sshdconfig",
    "systemd",
    "tar",
    "tmux",
    "typescript",
    "wget",
    "yaml",
    "zsh",
}

vim.filetype.add({
    extension = {},
    filename = {},
    pattern = {
        ["*Jenkinsfile*"] = "groovy",
    },
})
