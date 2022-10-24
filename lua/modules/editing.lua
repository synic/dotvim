return function(use)
	use("editorconfig/editorconfig-vim")
	use("tpope/vim-surround")
	use({
		"tpope/vim-commentary",
		config = function()
			vim.cmd([[
				function! ToggleComment()
					if mode() !~# "^[vV\<C-v>]"
						" not visual mode
						normal gcc
  				else
						visual gc
					endif
				endfunction

				:nmap <space>cl :call ToggleComment()<cr>
				:vmap <space>cl :call ToggleComment()<cr>
		]])
		end,
	})
	use({
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<space>tu", ":UndotreeToggle<cr>")
		end,
	})
end
