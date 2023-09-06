vim.api.nvim_set_option("guifont", "Hack:h10")

require("keymap")

local plugins = require("ao.plugins")
plugins.install_plugin_manager()
require("lazy").setup("modules", { change_detection = { enabled = true, notify = false } })
