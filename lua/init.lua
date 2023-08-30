vim.api.nvim_set_option("guifont", "Hack:h10")

local plugins = require("ao.plugins")

plugins.install_plugin_manager()

require("lazy").setup("modules", {
	change_detection = { enabled = true, notify = false },
})

vim.keymap.set("n", "<space>P", "<cmd>Lazy<cr>")
