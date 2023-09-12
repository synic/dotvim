return {
	{
		"dyng/ctrlsf.vim",
		cmd = { "CtrlSF" },
		config = function()
			vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
			vim.g.ctrlsf_default_view_mode = "normal"
			vim.g.ctrlsf_default_root = "project+wf"
			vim.g.ctrlsf_auto_close = {
				normal = 0,
				compact = 1,
			}
			vim.g.ctrlsf_auto_focus = {
				at = "start",
			}

			vim.cmd([[
				" search in the project root
				function! SearchInProjectRoot()
						call inputsave()
						let s:last_search_term = input('Search: ')
						call inputrestore()
						execute ':CtrlSF "' . s:last_search_term . '"'
				endfunction
			]])

			vim.api.nvim_set_keymap(
				"n",
				"<leader>sf",
				":call SearchInProjectRoot()<cr>",
				{ desc = "search in project root" }
			)
		end,
	},
	"haya14busa/incsearch.vim",
}
