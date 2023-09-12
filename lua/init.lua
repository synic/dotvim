require("keymap")
local functions = require("ao.functions")

vim.api.nvim_set_option("guifont", "Hack:h10")

local lazy, _ = functions.install_plugin_manager()

lazy.setup("modules", {
  change_detection = {
    enabled = true,
    notify = false,
  },
})
