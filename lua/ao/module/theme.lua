---@alias ColorSchemeCallback fun()
---@alias ColorSchemeEvent {match: string}
---
local setup_colors_group = vim.api.nvim_create_augroup("SetupColors", { clear = true })

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
local function on_colorscheme_load(pattern, cb)
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
			on_colorscheme_load("^gruvbox", set_whitespace_colors)
		end,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		keys = vim.deepcopy(keys),
		config = function()
			on_colorscheme_load("^catppuccin", function()
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
			on_colorscheme_load("^everforest", function()
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444" })
				vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "IblScope", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "NonText", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "Whitespace", { fg = "#555555" })
				vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#555555" })
			end)
		end,
	},
	{
		"rose-pine/neovim",
		keys = vim.deepcopy(keys),
		priority = 1000,
		name = "rose-pine",
		lazy = true,
		opts = {
			styles = {
				transparency = false,
			},
		},
		config = function(_, opts)
			local r = require("rose-pine")
			r.setup(opts)

			on_colorscheme_load("^rose%-pine", function()
				local highlights = vim.fn.getcompletion("", "highlight")
				for _, highlight in ipairs(highlights) do
					local current = vim.api.nvim_get_hl(0, { name = highlight })
					if current.blend then
						current.blend = 0
						---@diagnostic disable-next-line: param-type-mismatch
						vim.api.nvim_set_hl(0, highlight, current)
					end
				end

				vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#EBBCBA", bold = true, fg = "#191724", underline = false })
			end)
		end,
	},
	{ "EdenEast/nightfox.nvim", keys = vim.deepcopy(keys) },
	{
		"AlexvZyl/nordic.nvim",
		keys = vim.deepcopy(keys),
		priority = 1000,
		opts = {
			cursorline = {
				theme = "light",
				bold_number = true,
			},
			transparent = {
				bg = false,
				float = true,
			},
			bright_border = true,
		},
		config = function(_, opts)
			local nordic = require("nordic")
			nordic.setup(opts)
			---@diagnostic disable-next-line: missing-fields
			nordic.load({})

			on_colorscheme_load("^nordic", function()
				set_whitespace_colors()
				vim.cmd([[hi clear @spell]])
				vim.api.nvim_set_hl(0, "Delimiter", { fg = "#9c9aa2" })
				vim.api.nvim_set_hl(0, "FloatBorder", { link = "Comment" })
				vim.api.nvim_set_hl(0, "WinSeparator", { link = "Comment" })
				vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#383E4D", bold = true, bg = "#A3BE8C", underline = false })
				vim.api.nvim_set_hl(
					0,
					"TabLineFill",
					{ fg = "#242933", bold = true, bg = "#242933", underline = false }
				)
				vim.api.nvim_set_hl(0, "TabLine", { bg = "#383E4D", bold = true, fg = "#BBC3D4", underline = false })
				vim.api.nvim_set_hl(
					0,
					"SnacksPickerPickWin",
					{ fg = "#383E4D", bold = true, bg = "#EFD49F", underline = false }
				)
				vim.api.nvim_set_hl(
					0,
					"SnacksPickerPickWinCurrent",
					{ fg = "#383E4D", bold = true, bg = "#A3BE8C", underline = false }
				)

				vim.api.nvim_set_hl(0, "Comment", { cterm = { italic = true }, fg = "#616E88", italic = true })
			end)
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
