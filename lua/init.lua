vim.api.nvim_set_option("guifont", "Hack:h10")

-- neovide options
vim.g.neovide_remember_window_size = false
vim.g.neovide_remember_window_position = false

local f = require("core.functions")
f.ensure_package_manager()

local enabled_modules = {
	"projects",
	"language",
	"formatting",
	"completion",
	"filesystem",
	"vcs",
	"search",
	"motion",
	"themes",
	"editing",
	"debugging",
	"utils",
	"interface",
}

local plugins = {}

for module in enabled_modules do
	plugins = f.table_concat(plugins, require("modules." .. module)())
end

require("lazy").setup(plugins)
