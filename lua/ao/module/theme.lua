---@alias ColorSchemeCallback fun()
---@alias ColorSchemeEvent {match: string}
---
local setup_colors_group = vim.api.nvim_create_augroup("AoSetupColors", { clear = true })

---@type PluginModule
local M = {}

vim.api.nvim_create_autocmd("ColorScheme", {
	group = setup_colors_group,
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
		vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
		vim.api.nvim_set_hl(0, "SignatureMarkText", { link = "DiagnosticSignInfo" })
	end,
})

local function set_whitespace_colors()
	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
	vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
end

---@param pattern string Pattern to match colorscheme name against
---@param cb ColorSchemeCallback Callback to run when colorscheme loads
---@return nil
local function on_colorcheme_load(pattern, cb)
	cb()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		group = setup_colors_group,
		callback = function(cs)
			if cs.match:find(pattern) ~= nil then
				cb()
			end
		end,
	})
end

local function colorscheme_picker()
	require("snacks").picker.colorschemes()
end

local keys = {
	{ "<leader>st", colorscheme_picker, desc = "List themes" },
}

M.plugins = {
	{
		"sainnhe/gruvbox-material",
		keys = vim.deepcopy(keys),
		config = function()
			vim.g.gruvbox_material_background = "medium"
			on_colorcheme_load("^gruvbox", set_whitespace_colors)
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		keys = vim.deepcopy(keys),
		config = function()
			on_colorcheme_load("^catppuccin", function()
				vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#b4befe", bg = "#45475a" })
				set_whitespace_colors()
			end)
		end,
	},
	{
		"neanias/everforest-nvim",
		name = "everforest",
		keys = vim.deepcopy(keys),
		opts = {
			background = "hard",
			ui_contrast = "high",
		},
		config = function(_, opts)
			require("everforest").setup(opts)
			on_colorcheme_load("^everforest", function()
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444" })
				vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "NonText", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "Whitespace", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#555555" })
			end)
		end,
	},
	{ "rebelot/kanagawa.nvim", keys = vim.deepcopy(keys) },
	{ "Mofiqul/dracula.nvim", keys = vim.deepcopy(keys) },
	{ "EdenEast/nightfox.nvim", keys = vim.deepcopy(keys) },
	{ "oxfist/night-owl.nvim", keys = vim.deepcopy(keys) },
	{
		"AlexvZyl/nordic.nvim",
		keys = vim.deepcopy(keys),
		opts = {
			cursorline = {
				theme = "light",
			},
		},
		config = function(_, opts)
			local nordic = require("nordic")
			nordic.setup(opts)
			---@diagnostic disable-next-line: missing-fields
			nordic.load({})

			on_colorcheme_load("^nordic", function()
				set_whitespace_colors()
				vim.cmd([[hi clear @spell]])
				vim.api.nvim_set_hl(0, "Delimiter", { fg = "#9c9aa2" })
				vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment" })
				vim.api.nvim_set_hl(0, "WinSeparator", { link = "Comment" })
			end)
		end,
	},
	{
		"ribru17/bamboo.nvim",
		keys = vim.deepcopy(keys),
		config = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = setup_colors_group,
				pattern = "*",
				callback = function(o)
					if o.match:find("^bamboo") ~= nil then
						set_whitespace_colors()
					end
				end,
			})

			require("bamboo").setup({})
		end,
	},
	{
		"folke/tokyonight.nvim",
		keys = vim.deepcopy(keys),
		lazy = false,
		priority = 1000,
		opts = {},
	},
}

return M
