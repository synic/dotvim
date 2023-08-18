vim.g.EasyMotion_smartcase = true

return {
	{
		"Lokaltog/vim-easymotion",
		config = function()
			vim.keymap.set("", "<space><space>", "<plug>(easymotion-bd-f)")
			vim.keymap.set("n", "<space><space>", "<plug>(easymotion-overwin-f)")
		end,
	},

	{
		"justinmk/vim-sneak",
		config = function()
			vim.g["sneak#label"] = 1
		end,
	},
}
