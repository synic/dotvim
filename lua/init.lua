require("keymap")
local functions = require("ao.functions")

vim.api.nvim_set_option("guifont", "Hack:h10")

local lazy, installed = functions.install_plugin_manager()

lazy.setup("modules", {
  install = {
    install_missing = not installed,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})

if installed then
  lazy.install({ wait = true, show = false })
	functions.close_all_floating_windows()
end

if next(vim.fn.argv()) == nil then
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			require("modules.telescope").functions.telescope_load_projects()
		end,
	})
end
