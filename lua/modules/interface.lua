vim.g.golden_ratio_enabled = 0
vim.g.golden_ratio_autocmd = 0

return {
	"nvim-tree/nvim-web-devicons",
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{
		"roman/golden-ratio",
		keys = {
			{ "<space>tg", "<cmd>call ToggleGoldenRatio()<cr>", desc = "Golden Ratio" },
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
