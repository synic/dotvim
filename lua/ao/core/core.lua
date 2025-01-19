local config = require("ao.config")

---@class PluginSpec
---@field plugin_specs LazySpec[]|fun():LazySpec[]
---@field [string] any  -- Allow any additional functions/fields

---@alias PluginModule LazySpec[]|PluginSpec

local after_load_augroup = vim.api.nvim_create_augroup("AoVimAfterLoad", { clear = true })
local M = {}

local uv = vim.uv or vim.loop

---@return Lazy, boolean
function M.install_plugin_manager()
	local was_installed = false
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	---@diagnostic disable-next-line: undefined-field
	if not uv.fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})

		was_installed = true
	end

	vim.opt.rtp:prepend(lazypath)

	local lazy = require("lazy")
	return lazy, was_installed
end

---@param theme string
---@return boolean
local function load_theme(theme)
	require("lazy.core.loader").colorscheme(theme)
	local was_set = pcall(vim.cmd.colorscheme, theme)
	if not was_set then
		vim.notify("Unable to load colorscheme " .. theme, vim.log.levels.ERROR)
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return was_set
end

---@return LazySpec[]
function M.load_plugin_specs()
	local tbl = require("ao.core.tbl")

	---@type LazySpec[]
	local plugins = {}
	local path = vim.fn.stdpath("config") .. "/lua/ao/module"
	local items = vim.split(vim.fn.glob(vim.fn.resolve(path .. "/*.lua")), "\n", { trimempty = true })

	for _, item in ipairs(items) do
		---@type PluginModule
		local m = require("ao.module." .. vim.fn.fnamemodify(item, ":t:r"))
		local v = m.plugin_specs

		if v == nil then
			plugins = tbl.concat(plugins, m)
		else
			---@diagnostic disable-next-line: param-type-mismatch
			plugins = tbl.concat(plugins, (type(v) == "function" and v() or v))
		end
	end

	return plugins
end

---@param opts table
---@param startup_callback_fn? fun(): nil
---@return nil
function M.setup(opts, startup_callback_fn)
	local win = require("ao.core.win")

	config.options = vim.tbl_deep_extend("force", config.options, opts)
	if config.options.appearance.guifont then
		vim.o.guifont = config.options.appearance.guifont
	end

	local lazy, installed = M.install_plugin_manager()

	lazy.setup(M.load_plugin_specs(), config.options.lazy)
	lazy.install({ wait = installed, show = installed })

	local theme_load_status = false
	if config.options.appearance.theme then
		theme_load_status = load_theme(config.options.appearance.theme)
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		group = after_load_augroup,
		callback = function()
			if startup_callback_fn then
				startup_callback_fn()
			end

			if config.options.appearance.theme and not theme_load_status then
				require("lazy.core.loader").colorscheme(config.options.appearance.theme)
				vim.schedule(function()
					vim.cmd.colorscheme(config.options.appearance.theme)
				end)
			end
		end,
	})

	win.close_all_floating_windows()
end

return M
