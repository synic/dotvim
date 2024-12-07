local core = require("ao.core")

local config = {
	projects = {
		entries = {},
		directory = { path = os.getenv("HOME") .. "/Projects", skip = {} },
		root_names = { ".git", ".svn", ".project_root" },
	},
	appearance = {
		guifont = "Hack Nerd Font Mono:h12",
		theme = "duskfox",
	},
}

local ok, local_config = pcall(require, "local_config")
if ok then
	config = vim.tbl_deep_extend("force", config, local_config)
end

core.setup(config)
