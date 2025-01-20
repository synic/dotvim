local tbl = require("ao.tbl")
local config = require("ao.config")

local to_import = tbl.unique(config.options.languages, config.options.extra_languages)

---@type LazySpec[]
local plugins = {}
local treesitter = {}
local handlers = {}
local servers = {}
local nonels = {}
local langs = {}

for _, lang in ipairs(to_import) do
	table.insert(langs, lang)

	if vim.fn.filereadable(vim.fn.stdpath("config") .. "/ao/module/lang/" .. lang .. ".lua") then
		local ok, m = pcall(require, "ao.module.lang." .. lang)

		if not ok then
			vim.notify("unable to initialize language: " .. lang)
		else
			if m.plugins then
				plugins = tbl.concat(plugins, m.plugins)
			end

			if m.treesitter then
				treesitter = tbl.concat(treesitter, m.treesitter)
			end

			if m.handlers then
				handlers = vim.tbl_extend("force", handlers, m.handlers)

				for server, _ in pairs(m.handlers) do
					table.insert(servers, server)
				end
			end

			if m.servers then
				servers = tbl.concat(servers, m.servers)
			end

			if m.nonels then
				nonels = tbl.concat(nonels, m.nonels)
			end
		end
	end
end

plugins = tbl.concat(
	plugins,
	require("ao.module.lang.treesitter").get_plugins(tbl.unique(treesitter)),
	require("ao.module.lang.lsp").get_plugins(tbl.unique(langs), tbl.unique(servers), handlers, tbl.unique(nonels))
)

return { plugins = plugins }
