local wk_categories = require("keymap").categories

return {
	{
		"folke/which-key.nvim",
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(wk_categories)

			vim.o.timeout = true
			vim.o.timeoutlen = 700
		end,
		opts = {
			plugins = { spelling = true },
			mode = { "n", "v" },
			layout = { align = "center" },
			triggers_blacklist = {
				i = { "f", "d" },
				v = { "f", "d" },
			},
		},
	},

	{
		"nanozuki/tabby.nvim",
		event = "TabEnter",
		config = function()
			local theme = {
				fill = "TabLineFill",
				-- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
				head = "TabLine",
				current_tab = "TabLineSel",
				tab = "TabLine",
				win = "TabLine",
				tail = "TabLine",
			}
			require("tabby.tabline").set(function(line)
				return {
					{
						{ "  ", hl = theme.head },
						line.sep("", theme.head, theme.fill),
					},
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.current_tab or theme.tab
						return {
							line.sep("", hl, theme.fill),
							tab.is_current() and "" or "󰆣",
							tab.number(),
							tab.name(),
							tab.close_btn(""),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					{
						line.sep("", theme.tail, theme.fill),
						{ "  ", hl = theme.tail },
					},
					hl = theme.fill,
				}
			end)
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},

	-- colorschemes
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "synic/jellybeans.vim", lazy = true },
	{ "jnurmine/Zenburn", lazy = true },
	{ "morhetz/gruvbox", lazy = true },
	{ "synic/synic.vim", lazy = true },
	{ "lifepillar/vim-solarized8", lazy = true },
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		init = function()
			vim.g.gruvbox_material_background = "medium"
		end,
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	},
	{ "NLKNguyen/papercolor-theme", lazy = true },
	{
		"sainnhe/everforest",
		lazy = true,
		init = function()
			vim.g.everforest_background = "hard"
		end,
	},
	{ "gosukiwi/vim-atom-dark", lazy = true },
	{ "tomasr/molokai", lazy = true },
	{ "ray-x/aurora", lazy = true },
	{ "sainnhe/sonokai", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
}
