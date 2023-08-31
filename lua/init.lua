vim.api.nvim_set_option("guifont", "Hack:h10")

local plugins = require("ao.plugins")
require("keymap")

plugins.install_plugin_manager()

require("lazy").setup("modules", {
	change_detection = { enabled = true, notify = false },
})

vim.api.nvim_set_keymap("n", "<space>P", "<cmd>Lazy<cr>", { desc = "plugin manager", silent = true })
