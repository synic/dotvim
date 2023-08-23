vim.g.EasyMotion_smartcase = true

return {
	{
		"Lokaltog/vim-easymotion",
		keys = {
			{ "<space><space>", "<plug>(easymotion-overwin-f)", desc = "Jump to location" },
		},
	},

	{
		"justinmk/vim-sneak",
		config = function()
			vim.g["sneak#label"] = 1
		end,
	},
}
