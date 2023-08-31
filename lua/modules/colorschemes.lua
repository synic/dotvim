vim.api.nvim_set_keymap("n", "<space>tt", "<cmd>Telescope colorscheme<cr>", { desc = "colorschemes" })
vim.g.gruvbox_material_background = "medium"
vim.g.everforest_background = "hard"

return {
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "synic/jellybeans.vim", lazy = true },
	{ "jnurmine/Zenburn", lazy = true },
	{ "morhetz/gruvbox", lazy = true },
	{ "synic/synic.vim", lazy = true },
	{ "lifepillar/vim-solarized8", lazy = true },
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd("colorscheme gruvbox-material")
		end,
	},
	{ "NLKNguyen/papercolor-theme", lazy = true },
	{ "sainnhe/everforest", lazy = true },
	{ "gosukiwi/vim-atom-dark", lazy = true },
	{ "tomasr/molokai", lazy = true },
	{ "ray-x/aurora", lazy = true },
	{ "sainnhe/sonokai", lazy = true },
	{ "folke/tokyonight.nvim", lazy = true },
}
