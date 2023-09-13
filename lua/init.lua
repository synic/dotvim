require("keymap")
local functions = require("ao.functions")

vim.api.nvim_set_option("guifont", "Hack:h10")

local lazy, installed = functions.install_plugin_manager()

lazy.setup("modules", {
  install = {
    install_missing = false,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

lazy.install({ wait = installed, show = false })
functions.close_all_floating_windows()

if next(vim.fn.argv()) == nil then
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      functions.ensure_project_list()
      vim.cmd("doautocmd User LoadProjectList")
    end,
  })
end
