local keymap = require("ao.keymap")
local functions = require("ao.utils")

vim.api.nvim_set_option("guifont", "Hack:h10")

local lazy, installed = functions.install_plugin_manager()

lazy.setup("ao.modules", {
  install = { install_missing = false },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

lazy.install({ wait = installed, show = false })
functions.boostrap_project_list(os.getenv("HOME") .. "/Projects")
functions.install_keymap(keymap.general_keys)
functions.close_all_floating_windows()
