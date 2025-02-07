local core = require("ao.core")

---@type Config["options"]
---@diagnostic disable-next-line: missing-fields
local config = {
	projects = {
		entries = {},
		directory = { path = os.getenv("HOME") .. "/Projects", skip = {} },
		root_names = { ".git", ".svn", ".project_root", "mix.exs" },
	},
	appearance = {
		theme = "tokyonight",
	},
}

---@type boolean, Config["options"]|nil
local ok, local_config = pcall(require, "local_config")
if ok then
	config = vim.tbl_deep_extend("force", config, local_config)
end

core.setup(config)
