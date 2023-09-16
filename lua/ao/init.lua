local keymap = require("ao.keymap")
local utils = require("ao.utils")

vim.api.nvim_set_option("guifont", "Hack:h10")

local lazy, installed = utils.install_plugin_manager()

lazy.setup("ao.modules", {
  install = { install_missing = false },
  change_detection = { enabled = true, notify = false },
})

lazy.install({ wait = installed, show = false })
utils.boostrap_project_list(os.getenv("HOME") .. "/Projects")
utils.install_keymap(keymap.general_keys)
utils.close_all_floating_windows()
utils.lazy_load_theme("papercolor")
