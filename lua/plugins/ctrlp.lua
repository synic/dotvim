pcall(vim.fn["ctrlp_bdelete#init"])

vim.g.ctrlp_max_files = 100000
vim.g.ctrlp_match_window = "bottom:order:ttb,min:10,max:10,results:10"
vim.g.ctrlp_working_path_mode = "ra"
vim.g.ctrlp_user_command = 'ag %s --nocolor -ls -g ""'

-- vim.keymap.set("n", "<space>bb", ":CtrlPBuffer<cr>")
-- vim.keymap.set("n", "<space>ph", ":CtrlP<cr>")
