local keymap = require("ao.keymap")
keymap.add({
	{ "q", "<cmd>lua require('oil').close()<cr>", desc = "Close oil", buffer = true },
})
