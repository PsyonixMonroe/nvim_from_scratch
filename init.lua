vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

require("lazy_setup")

require("options")

require("keymap")

require("autocmd")

require("urlhighlight")

require("lang_server")

require("machine")

vim.cmd.colorscheme("astrodark")
