return function(use)
	use({
		"Lokaltog/vim-easymotion",
		config = function()
			vim.keymap.set("", "<space><space>", "<plug>(easymotion-bd-f)")
			vim.keymap.set("n", "<space><space>", "<plug>(easymotion-overwin-f)")
		end,
	})
	use("vim-scripts/quit-another-window")
end
