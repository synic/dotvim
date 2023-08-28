vim.api.nvim_set_option("guifont", "Hack:h10")

local core = require("ao.core")
core.ensure_package_manager()
require("lazy").setup("modules", {
	change_detection = { enabled = false },
})
