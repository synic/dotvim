vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.api.nvim_set_hl(0, "EasyMotionTarget", { link = "Search" })
		vim.api.nvim_set_hl(0, "LirDir", { link = "netrwDir" })
		vim.api.nvim_set_hl(0, "SignatureMarkText", { link = "DiagnosticSignInfo" })
	end,
})

local keys = {
	{ "<leader>st", "<cmd>ColorSchemePicker<cr>", desc = "List themes" },
}

-- don't display these themes in the picker
local skip_themes = {
	"zellner",
	"torte",
	"slate",
	"shine",
	"ron",
	"quiet",
	"peachpuff",
	"pablo",
	"murphy",
	"lunaperche",
	"koehler",
	"industry",
	"evening",
	"elflord",
	"desert",
	"delek",
	"default",
	"darkblue",
	"blue",
	"zaibatsu",
	"sorbet",
	"morning",
	"wildcharm",
}

local function set_whitespace_colors()
	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333333" })
	vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "IblScope", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "NonText", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "Whitespace", { fg = "#444444" })
	vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#444444" })
end

local function on_colorcheme_load(pattern, cb)
	cb()
	vim.api.nvim_create_autocmd("ColorScheme", {
		pattern = "*",
		callback = function(cs)
			if cs.match:find(pattern) ~= nil then
				cb()
			end
		end,
	})
end

vim.api.nvim_create_user_command("ColorSchemePicker", function()
	local target = vim.fn.getcompletion

	vim.fn.getcompletion = function()
		return vim.tbl_filter(function(color)
			return not vim.tbl_contains(skip_themes, color)
			---@diagnostic disable-next-line: redundant-parameter
		end, target("", "color"))
	end

	vim.cmd.Telescope("colorscheme")
	vim.fn.getcompletion = target
end, {})

return {
	{
		"sainnhe/gruvbox-material",
		keys = vim.deepcopy(keys),
		config = function()
			vim.g.gruvbox_material_background = "medium"
			on_colorcheme_load("^gruvbox", set_whitespace_colors)
		end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		keys = vim.deepcopy(keys),
		config = function()
			on_colorcheme_load("^rose%-pine", set_whitespace_colors)
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
	{ "folke/tokyonight.nvim", keys = vim.deepcopy(keys) },
	{ "bluz71/vim-nightfly-colors", name = "nightfly", keys = vim.deepcopy(keys) },
	{ "rebelot/kanagawa.nvim", keys = vim.deepcopy(keys) },
	{ "Mofiqul/dracula.nvim", keys = vim.deepcopy(keys) },
	{ "joshdick/onedark.vim", keys = vim.deepcopy(keys) },
	{ "EdenEast/nightfox.nvim", keys = vim.deepcopy(keys) },
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
			nordic.load()

			on_colorcheme_load("^nordic", function()
				vim.api.nvim_set_hl(0, "Delimiter", { fg = "#9c9aa2" })
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#333344" })
				vim.api.nvim_set_hl(0, "IblWhitespace", { fg = "#444455" })
				vim.api.nvim_set_hl(0, "IblScope", { fg = "#444455" })
				vim.api.nvim_set_hl(0, "NonText", { fg = "#333344" })
				vim.api.nvim_set_hl(0, "Whitespace", { fg = "#333344" })
				vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#333344" })
				vim.api.nvim_set_hl(0, "SpecialKey", { fg = "#333344" })
				vim.api.nvim_set_hl(0, "@spell", { link = "String" })
			end)
		end,
	},
	{
		"ribru17/bamboo.nvim",
		keys = vim.deepcopy(keys),
		config = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function(o)
					if o.match:find("^bamboo") ~= nil then
						set_whitespace_colors()
					end
				end,
			})

			local bamboo = require("bamboo")
			bamboo.setup({})
			bamboo.load()
		end,
	},
}
