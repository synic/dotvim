vim.g.golden_ratio_enabled = 0
vim.g.golden_ratio_autocmd = 0

return {
	{
		"folke/which-key.nvim",
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			wk.register(opts.defaults)

			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		opts = {
			plugins = { spelling = true },
			defaults = {
				mode = { "n", "v" },
				["g"] = { name = "+goto" },
				["gz"] = { name = "+surround" },
				["]"] = { name = "+next" },
				["["] = { name = "+prev" },
				["<space>rl"] = { name = "show last search" },
				["<space>P"] = { name = "manage plugins" },
				["<space>l"] = { name = "+layouts" },
				["<space>b"] = { name = "+buffers" },
				["<space>o"] = { name = "+info" },
				["<space>c"] = { name = "+code" },
				["<space>d"] = { name = "+debug" },
				["<space>f"] = { name = "+file/find" },
				["<space>fe"] = { name = "+misc" },
				["<space>h"] = { name = "+help" },
				["<space>m"] = { name = "+marks" },
				["<space>p"] = { name = "+project" },
				["<space>g"] = { name = "+git" },
				["<space>s"] = { name = "+search" },
				["<space>ss"] = { name = "+spelling" },
				["<space>t"] = { name = "+toggles" },
				["<space>u"] = { name = "+ui" },
				["<space>w"] = { name = "+windows" },
				["<space>e"] = { name = "+diagnostis/quickfix" },
				["<leader>gh"] = { name = "+hunks" },
			},
		},
	},
	"nvim-tree/nvim-web-devicons",
	{
		"rcarriga/nvim-notify",
		config = function()
			vim.notify = require("notify")
		end,
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
	{
		"roman/golden-ratio",
		keys = {
			{ "<space>tg", "<cmd>call ToggleGoldenRatio()<cr>", desc = "golden Ratio" },
		},
		lazy = true,
		config = function()
			vim.cmd([[
				function! ToggleGoldenRatio()
					execute ':GoldenRatioToggle'
					if g:golden_ratio_enabled == 0
						let g:golden_ratio_enabled = 1
						echo 'Enabled golden ratio'
					else
						let g:golden_ratio_enabled = 0
						echo 'Disabled golden ratio'
						set equalalways
						wincmd =
					endif
				endfunction
			]])

			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function()
					vim.cmd([[:GoldenRatioToggle]])
				end,
			})
		end,
	},
}
