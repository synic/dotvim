require("keymap")
local functions = require("ao.functions")

vim.api.nvim_set_option("guifont", "Hack:h10")

functions.install_plugin_manager()
require("lazy").setup("modules", { change_detection = { enabled = true, notify = false } })
