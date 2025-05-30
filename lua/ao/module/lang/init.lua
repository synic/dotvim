local config = require("ao.config")

local function unique(...)
	return vim.fn.uniq(vim.fn.sort(vim.iter({ ... }):flatten():totable()))
end

local to_import = unique(config.options.languages, config.options.extra_languages)

---@type LazySpec[]
local plugins = {}
local lang_defs = {}

---@diagnostic disable-next-line: param-type-mismatch
for _, lang in ipairs(to_import) do
	if vim.fn.filereadable(vim.fn.stdpath("config") .. "/ao/module/lang/" .. lang .. ".lua") then
		local ok, m = pcall(require, "ao.module.lang." .. lang)

		if not ok then
			vim.notify("unable to initialize language: " .. lang)
		else
			table.insert(lang_defs, m)

			if m.plugins then
				plugins = vim.iter({ plugins, m.plugins }):flatten():totable()
			end
		end
	end
end

plugins = vim.iter({
	plugins,
	require("ao.module.lang.treesitter").get_plugins(lang_defs),
	require("ao.module.lang.lsp").get_plugins(lang_defs),
})
	:flatten()
	:totable()

return { plugins = plugins }
