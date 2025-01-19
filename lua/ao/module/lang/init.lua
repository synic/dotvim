local tbl = require("ao.tbl")

---@type PluginModule
local M = { plugin_specs = {} }

local path = vim.fn.stdpath("config") .. "/lua/ao/module/lang"
local items = vim.split(vim.fn.glob(vim.fn.resolve(path .. "/*.lua")), "\n", { trimempty = true })

for _, item in ipairs(items) do
	if not item:match("init.lua$") then
		local m = require("ao.module.lang." .. vim.fn.fnamemodify(item, ":t:r"))
		local v = m.plugin_specs
		M = tbl.concat(M, m)
		if v ~= nil then
			M.plugin_specs = tbl.concat(M.plugin_specs, v)
		end
	end
end

return M
