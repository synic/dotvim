vim.opt_local.foldmethod = "marker"
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

vim.keymap.set("n", "<localleader>W", "<Plug>(DBUI_SaveQuery)", { buffer = true, desc = "Save query" })
vim.keymap.set(
	"n",
	"<localleader>E",
	"<Plug>(DBUI_EditBindParameters)",
	{ buffer = true, desc = "Edit bind parameters" }
)
vim.keymap.set("n", "<localleader>S", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute query" })
vim.keymap.set("v", "<localleader>S", "<Plug>(DBUI_ExecuteQuery)", { buffer = true, desc = "Execute query" })
