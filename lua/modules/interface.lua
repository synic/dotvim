vim.g.golden_ratio_enabled = 0
vim.g.golden_ratio_autocmd = 0

return {
	{
		"bling/vim-airline",
		config = function()
			vim.g.airline_powerline_fonts = 1
			vim.g["airline#extensions#tabline#enabled"] = 1
			vim.g["airline#extensions#tabline#tab_nr_type"] = 1
			vim.g["airline#extensions#tabline#tab_min_count"] = 2
			vim.g["airline#extensions#tabline#show_splits"] = 0
			vim.g["airline#extensions#tabline#show_buffers"] = 0
			vim.g["airline#extensions#tabline#show_tab_type"] = 0
			vim.g["airline#extensions#whitespace#enabled"] = 0
		end,
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
