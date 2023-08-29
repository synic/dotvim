vim.api.nvim_set_option("guifont", "Hack:h10")

local core = require("ao.core")

core.bootstrap_package_manager()

require("lazy").setup("modules", {
	change_detection = { enabled = true, notify = false },
})

vim.keymap.set("n", "<space>P", "<cmd>Lazy<cr>")
