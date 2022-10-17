return function(use)
	use({
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
	})
end
