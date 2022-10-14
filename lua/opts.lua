vim.g.mapleader = ","

vim.cmd("colorscheme jellybeans")

vim.opt.filetype = "on"
vim.opt.filetype.indent = "on"
vim.opt.filetype.plugin = "on"

vim.opt.encoding = "utf-8"

vim.opt.bs = "2"
vim.opt.cindent = true
vim.opt.si = true
vim.opt.viminfo = "'20,\"50"
vim.opt.history = 50
vim.opt.ruler = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.visualbell = true
vim.opt.incsearch = true
vim.opt.syntax = "on"
vim.opt.compatible = false
vim.opt.hlsearch = true
vim.opt.laststatus = 2
vim.opt.vb = true
vim.opt.ruler = true
vim.opt.spelllang = "en_US"
vim.opt.autoindent = true
vim.opt.colorcolumn = "80"
vim.opt.textwidth = 78
vim.opt.clipboard = "unnamed"
vim.opt.scrollbind = false
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.equalalways = true

vim.opt.statusline = "%<%n:%f%h%m%r%= %{&ff} %l,%c%V %P"

vim.opt.mouse = "a"
vim.opt.mousehide = true
vim.opt.mousemodel = "extend"

vim.opt.modeline = true
vim.opt.modelines = 5

vim.opt.showmatch = true
vim.opt.matchtime = 5

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.shiftround = true
vim.opt.expandtab = true

vim.opt.formatoptions = vim.opt.formatoptions + "t"
vim.opt.hidden = true

vim.opt.number = true
vim.opt.exrc = true
vim.opt.secure = true

vim.keymap.set("i", "fd", "<esc>", { noremap = true })
vim.keymap.set("v", "fd", "<esc>", { noremap = true })

vim.keymap.set("n", "<space>wk", ":wincmd k<cr>", { silent = true })
vim.keymap.set("n", "<space>wj", ":wincmd j<cr>", { silent = true })
vim.keymap.set("n", "<space>wh", ":wincmd h<cr>", { silent = true })
vim.keymap.set("n", "<space>wl", ":wincmd l<cr>", { silent = true })
vim.keymap.set("n", "<space><tab>", ":b#<cr>", { silent = true })
vim.keymap.set("n", "<space>w/", ":vs<cr>", { silent = true })
vim.keymap.set("n", "<space>w-", ":sp<cr>", { silent = true })
vim.keymap.set("n", "<space>w-", ":sp<cr>", { silent = true })
vim.keymap.set("n", "<space>wd", ":close<cr>", { silent = true })

vim.keymap.set("n", "<space>fes", ":FzfLua grep_project<cr>", { silent = true })

vim.keymap.set("n", "<space>fed", ":e ~/.config/nvim/lua<cr>")
