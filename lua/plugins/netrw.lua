local f = require("functions")

vim.g.netrw_liststyle = 1
vim.g.netrw_banner = 0
vim.g.netrw_list_hide = (vim.fn["netrw_gitignore#Hide"]()) .. [[,\(^\|\s\s\)\zs\.\S\+]]
vim.g.NERDTreeHijackNetrw = 0

vim.keymap.set("n", "-", f.netrw_current_file)
vim.keymap.set("n", "_", f.netrw_current_project)
