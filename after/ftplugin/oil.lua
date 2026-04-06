local keymap = require("modules.keymap")
vim.bo.textwidth = 0
keymap.add({
	{ "q", "<cmd>lua require('oil').close()<cr>", desc = "Close oil", buffer = true },
})
