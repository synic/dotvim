local core = require("ao.core")
local config = require("ao.config")

---@type boolean, Config["options"]|nil
local ok, local_config = pcall(require, "local_config")
if ok then
	config = vim.tbl_deep_extend("force", config, local_config)
end

core.setup(config)
