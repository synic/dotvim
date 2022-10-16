return function(use)
	use({
		"Lokaltog/vim-easymotion",
		config = function()
			vim.keymap.set("", "<leader><leader>", "<plug>(easymotion-bd-f)")
			vim.keymap.set("n", "<leader><leader>", "<plug>(easymotion-overwin-f)")
		end,
	})
	use("vim-scripts/quit-another-window")
end
