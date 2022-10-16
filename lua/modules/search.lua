return function(use)
	use({
		"smjonas/inc-rename.nvim",
		config = function()
			require("inc_rename").setup()

			vim.keymap.set("n", "<leader>r", function()
				return ":IncRename " --.. vim.fn.expand("<cword>")
			end, { expr = true })
		end,
	})
	use({
		"dyng/ctrlsf.vim",
		config = function()
			vim.g.better_whitespace_filetypes_blacklist = { "ctrlsf" }
			vim.g.ctrlsf_default_view_mode = "compact"
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

			vim.keymap.set("n", "<leader>*", ":CtrlSF<cr>")
			vim.keymap.set("n", "<leader>Sp", ":call SearchInProjectRoot()<cr>")
		end,
	})
	use("haya14busa/incsearch.vim")
end
