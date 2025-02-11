local config = require("ao.config")

local function unique(...)
	return vim.fn.uniq(vim.fn.sort(vim.iter({ ... }):flatten():totable()))
end

local to_import = unique(config.options.languages, config.options.extra_languages)

---@type LazySpec[]
local plugins = {}
local treesitter = {}
local handlers = {}
local servers = {}
local nonels = {}
local langs = {}

---@diagnostic disable-next-line: param-type-mismatch
for _, lang in ipairs(to_import) do
	table.insert(langs, lang)

	if vim.fn.filereadable(vim.fn.stdpath("config") .. "/ao/module/lang/" .. lang .. ".lua") then
		local ok, m = pcall(require, "ao.module.lang." .. lang)

		if not ok then
			vim.notify("unable to initialize language: " .. lang)
		else
			if m.plugins then
				plugins = vim.iter({ plugins, m.plugins }):flatten():totable()
			end

			if m.treesitter then
				treesitter = vim.iter({ treesitter, m.treesitter }):flatten():totable()
			end

			if m.servers then
				for server, handler in pairs(m.servers) do
					if type(server) == "number" then
						table.insert(servers, handler)
					else
						table.insert(servers, server)
						handlers[server] = handler
					end
				end
			end

			if m.nonels then
				for k, v in pairs(m.nonels) do
					if type(k) == "number" then
						table.insert(nonels, v)
					else
						nonels[k] = v
					end
				end
			end
		end
	end
end

plugins = vim.iter({
	plugins,
	require("ao.module.lang.treesitter").get_plugins(unique(treesitter)),
	require("ao.module.lang.lsp").get_plugins(unique(langs), unique(servers), handlers, nonels),
})
	:flatten()
	:totable()

return { plugins = plugins }
